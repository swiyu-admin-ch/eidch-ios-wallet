import BITTheming
import Factory
import Foundation
import SwiftUI


struct DebugSubmitEIDRequestView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.submitEIDRequestFilesViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    List {
      Section {
        if !viewModel.fileUploads.isEmpty {
          VStack(spacing: .x4) {
            HStack {
              Text("Overall Progress")
                .font(.headline)
              Spacer()
              Text("\(Int(viewModel.overallProgress * 100))%")
                .font(.headline)
                .foregroundColor(.primary)
            }

            ProgressView(value: viewModel.overallProgress)
              .progressViewStyle(.linear)
              .scaleEffect(x: 1, y: 2, anchor: .center)
          }
        }
      }

      Section {
        ForEach(Array(viewModel.fileUploads.values), id: \.file.id) { uploadInfo in
          FileUploadRow(
            uploadInfo: uploadInfo,
            onRetry: {
              Task {
                await viewModel.retryFileUpload(uploadInfo.file.id)
              }
            })
        }
      }
    }
    .safeAreaInset(edge: .bottom, content: {
      footer()
    })
    .onFirstAppear {
      Task {
        await viewModel.submit()
      }
    }
  }

  // MARK: Private

  @StateObject private var viewModel: SubmitEIDRequestFilesViewModel

  @ViewBuilder
  private func footer() -> some View {
    VStack(spacing: 12) {
      if !viewModel.failedFiles.isEmpty {
        Button(action: {
          Task {
            await viewModel.retryFailedUploads()
          }
        }) {
          HStack {
            Image(systemName: "arrow.clockwise")
            Text("Retry Failed Uploads (\(viewModel.failedFiles.count))")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.orange)
          .foregroundColor(.white)
          .cornerRadius(12)
        }
      }

      if viewModel.areAllFilesCompleted {
        Button(action: {
          Task {
            await viewModel.submitEidRequest()
          }
        }) {
          HStack {
            Image(systemName: "checkmark.circle.fill")
            Text("Complete Submission")
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.green)
          .foregroundColor(.white)
          .cornerRadius(12)
        }
      }
    }
    .padding(.horizontal)
    .padding(.bottom)
  }

}

// MARK: - FileUploadRow

struct FileUploadRow: View {

  let uploadInfo: FileUploadInfo
  let onRetry: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "doc.fill")
        .foregroundColor(.blue)
        .frame(width: 24, height: 24)

      Text(uploadInfo.file.fileName)
        .font(.body)
        .fontWeight(.medium)
        .lineLimit(2)

      Spacer()

      switch uploadInfo.state {
      case .pending:
        HStack {
          Text("Pending")
            .font(.caption)
            .foregroundColor(.secondary)
          ProgressView()
            .scaleEffect(0.7)
        }

      case .uploading(let progress):
        VStack(spacing: 4) {
          HStack {
            Text("\(Int(progress * 100))%")
              .font(.caption)
              .fontWeight(.medium)
            ProgressView()
              .scaleEffect(0.7)
          }
          ProgressView(value: progress)
            .frame(width: 60)
            .scaleEffect(x: 1, y: 0.5)
        }

      case .completed:
        VStack {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
            .font(.title2)
          Text("Done")
            .font(.caption)
            .foregroundColor(.green)
        }

      case .failed(let error):
        VStack(spacing: 4) {
          HStack {
            Image(systemName: "exclamationmark.triangle.fill")
              .foregroundColor(.red)
            Button("Retry") {
              onRetry()
            }
            .font(.caption)
            .foregroundColor(.blue)
          }
          Text("Failed")
            .font(.caption)
            .foregroundColor(.red)
        }
      }
    }
    .padding()
  }

}
