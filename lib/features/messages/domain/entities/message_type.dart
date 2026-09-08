/// What kind of content a [Message] carries — [image] and [file] both
/// populate `attachmentUrl`, [text] populates `text` only.
enum MessageType { text, image, file }
