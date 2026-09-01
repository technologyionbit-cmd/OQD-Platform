/// Deliberately independent of `ContractStatus` — a document's status
/// vocabulary won't necessarily match a contract's once uploaded documents
/// (with their own processing/review states) exist, so this feature isn't
/// coupled to `features/contracts` for it.
enum DocumentSourceType { generatedContract, uploaded }
