/// Drives which input widget [ContractFieldWidget] renders — extend this
/// (and that dispatcher) together when a template needs a new kind of
/// field; nothing else in the form architecture changes per contract type.
enum ContractFieldType { text, multiline, number, date, dropdown, phone, email, currency }
