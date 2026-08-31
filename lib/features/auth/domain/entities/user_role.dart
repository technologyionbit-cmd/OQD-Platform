/// Drives UX only (which shell/nav the app shows). The backend remains the
/// sole authority on what a given role is actually allowed to do — this
/// enum must never be treated as an authorization mechanism.
enum UserRole { client, lawyer, company }
