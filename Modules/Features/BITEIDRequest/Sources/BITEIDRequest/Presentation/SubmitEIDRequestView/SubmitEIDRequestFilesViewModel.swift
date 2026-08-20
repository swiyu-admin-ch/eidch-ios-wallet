import BITEIDRequestShared
import BITNetworking
import BITTheming
import Factory
import Foundation


@MainActor
@Observable
final class SubmitEIDRequestFilesViewModel {

  // MARK: Internal

  var fileUploads = [UUID: FileUploadInfo]()
  var destination: EIDRequestDestinations?

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
    guard let caseId = context.caseId else {
      return destination = .error(.retry(EidRequestError.missingContextInformations, { [weak self] _ in
        self?.retryAction()
      }))
    }

    do {
      let files = try await getEIDRequestFilesUseCase.execute(caseId: caseId)
      let renamedFiles = renameFiles(files).filter { allowedFiles.contains($0.fileName) }

      await sendFiles(renamedFiles)

      if areAllFilesCompleted {
        await submitEidRequest(renamedFiles)
      }
    } catch {
      destination = .error(.retry(error, { [weak self] _ in
        self?.retryAction()
      }))
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

  func submitEidRequest(_ files: [EIDRequestCaseFile]) async {
    guard let caseId = context.caseId, let authJwt = context.autoVerificationResponse?.jwt else {
      return destination = .error(.retry(EidRequestError.missingContextInformations, { [weak self] _ in
        self?.retryAction()
      }))
    }

    do {
      try await submitEIDRequestUseCase(caseId: caseId, authJwt: authJwt, files: files)
      try await deleteEIDRequestCaseFileUseCase.execute(forRequestCaseId: caseId)

      Container.shared.eidRequestContext.reset()
      destination = .success(caseId: caseId)
    } catch {
      destination = .error(.retry(error, { [weak self] _ in
        Task {
          await self?.submitEidRequest(files)
        }
      }))
    }
  }

  func retryAction() {
    Task {
      await retryFailedUploads()
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.sidFilenameMap) private var filenameMap
  @ObservationIgnored @Injected(\.sidAllowedFiles) private var allowedFiles

  @ObservationIgnored @Injected(\.getEIDRequestCaseFilesUseCase) private var getEIDRequestFilesUseCase: GetEIDRequestCaseFilesUseCaseProtocol
  @ObservationIgnored @Injected(\.submitEIDRequestFileUseCase) private var submitEIDRequestFileUseCase: SubmitEIDRequestFileUseCaseProtocol
  @ObservationIgnored @Injected(\.submitEIDRequestUseCase) private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol
  @ObservationIgnored @Injected(\.deleteEIDRequestCaseFileUseCase) private var deleteEIDRequestCaseFileUseCase: DeleteEIDRequestCaseFileUseCaseProtocol

  private func sendFiles(_ files: [EIDRequestCaseFile]) async {
    guard let caseId = context.caseId, let authJwt = context.autoVerificationResponse?.jwt else {
      return destination = .error(.retry(EidRequestError.missingContextInformations, { [weak self] _ in
        self?.retryAction()
      }))
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
      try await submitEIDRequestFileUseCase.execute(caseId: caseId, file: file, authJwt: authJwt, progressHandler)
      fileUploads[file.id]?.state = .completed
    } catch {
      fileUploads[file.id]?.state = .failed(error)
    }
  }

  @MainActor
  private func updateProgress(_ id: UUID, progress: Double) {
    fileUploads[id]?.state = .uploading(progress: progress)
  }

  private func renameFiles(_ files: [EIDRequestCaseFile]) -> [EIDRequestCaseFile] {
    let uniqueFiles = Dictionary(grouping: files, by: \.fileName).values.compactMap { $0.max(by: { $0.createdAt < $1.createdAt }) }

    return uniqueFiles.map { file in
      guard let filename = filenameMap[file.fileName] ?? nil else {
        return file
      }

      return EIDRequestCaseFile(id: file.id, fileName: filename, mime: file.mime, data: file.data, category: file.category)
    }
  }
}

// MARK: - FileUploadState

enum FileUploadState: Equatable {
  case pending
  case uploading(progress: Double)
  case completed
  case failed(Error)

  // MARK: Internal

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

  // MARK: Lifecycle

  init(file: EIDRequestCaseFile) {
    self.file = file
    state = .pending
  }

  // MARK: Internal

  let file: EIDRequestCaseFile
  var state: FileUploadState

}
