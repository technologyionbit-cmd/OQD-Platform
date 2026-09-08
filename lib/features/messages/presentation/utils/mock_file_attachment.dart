/// A mock file's display name/size, packed into `Message.attachmentUrl` so
/// no new field is needed on the Phase-1 [Message] entity. Presentation-only
/// concern — how the chat mock encodes a fake file reference into a plain
/// string — never leaks into the domain/data layers, which just see an
/// opaque `attachmentUrl`.
class MockFileAttachment {
  const MockFileAttachment({required this.fileName, required this.sizeLabel});

  final String fileName;
  final String sizeLabel;

  static const _scheme = 'mock-file://';
  static const _delimiter = '::';

  String encode() => '$_scheme$fileName$_delimiter$sizeLabel';

  /// Returns `null` if [attachmentUrl] isn't a mock-file reference (e.g. an
  /// image message's `attachmentUrl`, or null).
  static MockFileAttachment? tryDecode(String? attachmentUrl) {
    if (attachmentUrl == null || !attachmentUrl.startsWith(_scheme)) return null;
    final payload = attachmentUrl.substring(_scheme.length);
    final parts = payload.split(_delimiter);
    if (parts.length != 2) return MockFileAttachment(fileName: payload, sizeLabel: '');
    return MockFileAttachment(fileName: parts[0], sizeLabel: parts[1]);
  }
}

/// Small deterministic pool of realistic legal-document names/sizes for the
/// mock "attach a file" action (no real file-picker dependency) — the same
/// consultation, at the same point in its transcript, always offers the
/// same file so manual QA and tests are reproducible.
const _mockFilePool = [
  MockFileAttachment(fileName: 'legal_document.pdf', sizeLabel: '240 KB'),
  MockFileAttachment(fileName: 'contract_draft.docx', sizeLabel: '85 KB'),
  MockFileAttachment(fileName: 'power_of_attorney.pdf', sizeLabel: '412 KB'),
  MockFileAttachment(fileName: 'id_copy.jpg', sizeLabel: '1.1 MB'),
];

MockFileAttachment pickMockFileAttachment({required String consultationId, required int messageCountSoFar}) {
  final seed = (consultationId.hashCode.abs() + messageCountSoFar) % _mockFilePool.length;
  return _mockFilePool[seed];
}
