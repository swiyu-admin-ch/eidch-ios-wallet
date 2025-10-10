import BITEIDRequestShared
import BITNetworking
import Factory
import Foundation


@MainActor
class SubmitEIDRequestFilesViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @Published var fileUploads = [UUID: FileUploadInfo]()

  /// Overall upload progress (0.0 to 1.0)
  var overallProgress: Double {
    guard !fileUploads.isEmpty else { return 0.0 }

    let totalProgress = fileUploads.values.reduce(0.0) { total, uploadInfo in
      switch uploadInfo.state {
      case .failed,
           .pending:
        total + 0.0
      case .uploading(let progress):
        total + progress
      case .completed:
        total + 1.0
      }
    }

    return totalProgress / Double(fileUploads.count)
  }

  var areAllFilesCompleted: Bool {
    !fileUploads.isEmpty && fileUploads.values.allSatisfy { $0.state == .completed }
  }

  var failedFiles: [FileUploadInfo] {
    fileUploads.values.compactMap {
      if case .failed = $0.state { return $0 }
      return nil
    }
  }

  func submit() async {
    guard let caseId = router.context.caseId else {
      return router.eIDRequestError(error: EidRequestError.missingContextInformations, delegate: self)
    }

    do {
      let files = try await getEIDRequestFilesUseCase.execute(caseId: caseId)
      await sendFiles(files)

      if areAllFilesCompleted {
        await submitEidRequest()
      }
    } catch {
      router.eIDRequestError(error: error, delegate: self)
    }
  }

  func retryFailedUploads() async {
    let failedFileInfos = failedFiles
    guard !failedFileInfos.isEmpty else { return }

    for fileInfo in failedFileInfos {
      fileUploads[fileInfo.file.id]?.state = .pending
    }

    await sendFiles(failedFileInfos.map(\.file))
  }

  func retryFileUpload(_ fileId: UUID) async {
    guard
      let uploadInfo = fileUploads[fileId],
      case .failed = uploadInfo.state else { return }

    guard let caseId = router.context.caseId, let authJwt = router.context.authJwt else { return }

    fileUploads[fileId]?.state = .pending
    await upload(uploadInfo.file, caseId: caseId, authJwt: authJwt)

    if areAllFilesCompleted {
      await submitEidRequest()
    }
  }

  func submitEidRequest() async {
    do {
      guard let caseId = router.context.caseId, let authJwt = router.context.authJwt else {
        return router.eIDRequestError(error: EidRequestError.missingContextInformations, delegate: self)
      }

      #warning("Move to successfully sent files screen (for now: back home)")
      router.close()
    } catch {
      router.eIDRequestError(error: error, delegate: self)
    }
  }

  // MARK: Private

  private var router: EIDRequestInternalRoutes

  @Injected(\.getEIDRequestCaseFilesUseCase) private var getEIDRequestFilesUseCase
  @Injected(\.submitEIDRequestFileUseCase) private var submitEIDRequestFileUseCase
  @Injected(\.submitEIDRequestUseCase) private var submitEIDRequestUseCase

  private func sendFiles(_ files: [EIDRequestCaseFile]) async {
    guard let caseId = router.context.caseId, let authJwt = router.context.authJwt else {
      return router.eIDRequestError(error: EidRequestError.missingContextInformations, delegate: self)
    }

    for file in files {
      fileUploads[file.id] = FileUploadInfo(file: file)
    }

    await withTaskGroup(of: Void.self) { group in
      for file in files {
        group.addTask {
          await self.upload(file, caseId: caseId, authJwt: authJwt)
        }
      }
      await group.waitForAll()
    }
  }

  private func upload(_ file: EIDRequestCaseFile, caseId: String, authJwt: String) async {
    let progressHandler: ProgressHandler = { [weak self] response in
      self?.updateProgress(file.id, progress: Double(response.progress))
    }

    updateProgress(file.id, progress: 0.0)

    do {
      try await submitEIDRequestFileUseCase.execute(
        caseId: caseId,
        file: file,
        authJwt: authJwt,
        progressHandler)
      fileUploads[file.id]?.state = .completed
    } catch {
      fileUploads[file.id]?.state = .failed(error)
    }
  }

  @MainActor
  private func updateProgress(_ id: UUID, progress: Double) {
    fileUploads[id]?.state = .uploading(progress: progress)
  }
}


extension SubmitEIDRequestFilesViewModel: EIDRequestErrorDelegate {

  func primaryAction(error: any Error) {
    Task {
      await retryFailedUploads()
    }
  }

  func close() {
    router.close()
  }

}

// MARK: - FileUploadState

enum FileUploadState: Equatable {
  case pending
  case uploading(progress: Double)
  case completed
  case failed(Error)

  static func == (lhs: FileUploadState, rhs: FileUploadState) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed),
         (.pending, .pending):
      true
    case (.uploading(let lhsProgress), .uploading(let rhsProgress)):
      lhsProgress == rhsProgress
    case (.failed(let lhsError), .failed(let rhsError)):
      lhsError.localizedDescription == rhsError.localizedDescription
    default:
      false
    }
  }
}

// MARK: - FileUploadInfo

struct FileUploadInfo {
  let file: EIDRequestCaseFile
  var state: FileUploadState

  init(file: EIDRequestCaseFile) {
    self.file = file
    state = .pending
  }
}
