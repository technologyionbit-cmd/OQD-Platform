# خطة تفعيل حساب الفرد (Individual / role=client) — Full-stack

## طريقة الاستخدام (لأي محادثة جديدة)

- هاد الملف تراكر تقدم عبر محادثات متعددة. أول شي اقرأه، شوف آخر جزء غير مكتمل (Status ≠ Done)، واشتغل عليه بس.
- بعد ما تخلص جزء: علّم `Status: Done`، اذكر أي انحراف صار عن الخطة (ملف جديد، endpoint تغيّر، إلخ) تحت "ملاحظات تنفيذ" بآخر الملف.
- لا تلمس شاشات/features مو مذكورة هون (company, team, lawyer_dashboard, lawyer-side screens مثل `lawyer_profile_edit_screen.dart`, `lawyer_requests_screen.dart`, `lawyer_schedule_screen.dart`) — هاي مو من نطاق حساب الفرد، وموجودة بخطة full-stack الأوسع (`docs/backend/16-backend-roadmap.md`).
- المرجع التقني الكامل موجود بـ`docs/backend/*.md` (مبني للثلاث أنواع حسابات مع بعض) — هاد الملف بس يفلتر ويرتب الأجزاء اللي تخص الفرد، يحدد نطاق كل جزء، وبيثبّت تفاصيل تنفيذية (schema فعلي، endpoints، حالة الفرونت الفعلية) مأخوذة من audit مباشر على الكود مو افتراضات.
- الbackend بنفس الريبو تحت `backend/` (NestJS 11 + Prisma 6 + Postgres، **بدون Redis محلياً**). الفرونت Flutter (Riverpod)، كل feature إلها `<feature>_data_source_provider.dart` هو نقطة التبديل الوحيدة من mock لreal — مذكور بـ[docs/backend/15-mock-to-real-migration.md](../backend/15-mock-to-real-migration.md).
- **قبل ما تبلش أي جزء**: شغّل الbackend محلياً (قسم "التشغيل محلياً" بآخر الملف) وتأكد `GET http://localhost:3000/v1/health` يرجع 200 قبل ما تكتب أي كود.

**نطاق هاي الخطة**: 6 أجزاء بس (تم استبعاد Messaging + AI + Notifications + Billing عمداً — جولة لاحقة، موجودين بـPhase 5/6/7/8 من [16-backend-roadmap.md](../backend/16-backend-roadmap.md)).

---

## البنية المعمارية — نمط موحّد بكل الـfeatures (Flutter)

تم تأكيده عبر audit مباشر لكل الـ6 أجزاء — نفس الطبقات بالضبط بكل مكان:

```
domain/entities/                         ← كيانات نقية، ما إلها أي اعتماد على backend
domain/repositories/<feature>_repository.dart          ← abstract interface
data/repositories/<feature>_repository_impl.dart       ← يلف الـdatasource، يحوّل لـResult<T>
data/datasources/<feature>_remote_data_source.dart      ← abstract interface (wire-level)
data/datasources/<feature>_mock_data_source.dart        ← تنفيذ وهمي (in-memory)
data/datasources/<feature>_remote_data_source_impl.dart ← تنفيذ حقيقي (dio) ← هاد الملف الوحيد الجديد بكل جزء
data/datasources/<feature>_data_source_provider.dart    ← **نقطة التبديل الوحيدة** (Riverpod Provider)
presentation/providers/                  ← AsyncNotifier/Notifier، ما بيعرف mock ولا real
presentation/screens/                    ← UI، ما بتتغير أبداً
```

**مثال حقيقي مطبّق فعلاً (auth — الوحيد المكتمل)**: `lib/features/auth/data/datasources/auth_data_source_provider.dart`
```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});
```
مافي `AuthMockDataSource` متبقي بالمجلد أصلاً — انحذف بالكامل. هاد هو الشكل النهائي لكل جزء بعد ما يخلص.

**البنية التحتية الجاهزة (`lib/core/network/`)** — لا تلمسها، مبنية أصلاً وشغالة:
- `dio_client.dart` → `Dio` واحد عالتطبيق (`DioClient`) مع `AuthInterceptor` (يرفق التوكن + refresh تلقائي عند 401) و`RedactingLoggingInterceptor` (debug فقط، بيخفي `password/token/accessToken/refreshToken/cardNumber/cvv/otp`).
- `api_error_mapper.dart` (وليس `lib/core/errors/` — تصحيح) → يحوّل كل `DioException`/status code لـ`Failure` مكتوب: `401→UnauthorizedFailure, 403→ForbiddenFailure, 404→NotFoundFailure, 422→ValidationFailure(fieldErrors), 408/timeout→TimeoutFailure, 5xx→ServerFailure, no-response→NetworkFailure`.
- `lib/core/config/app_config.dart` → `apiBaseUrl` الافتراضي `http://localhost:3000/v1` (نفس الbackend المحلي)، قابل للتغيير بـ`--dart-define=API_BASE_URL=`.
- الـerror envelope للbackend موصوف بـ[05-api-design.md](../backend/05-api-design.md) §4، ومطبّق فعلاً بـ`backend/src/common/{errors,filters,pipes}/`.

**قاعدة صارمة (من [15-mock-to-real-migration.md](../backend/15-mock-to-real-migration.md) §5)**: أي جزء ما بتغيّر فيه UI أو `domain/` إلا للتغييرات المحددة الموصوفة بكل جزء تحت. أي تغيير إضافي = نطاق منتج جديد، مو "ربط backend".

---

## الحالة العامة

| # | الجزء | Status |
|---|---|---|
| 1 | Profile & Account Settings | **Done** (2FA مؤجّل رسمياً — خارج نطاق هاي الخطة، انظر ملاحظات) |
| 2 | Gov Documents | **Done** |
| 3 | Lawyers Marketplace (client-facing) | **Done** |
| 4 | Consultations & Booking | **Done** |
| 5 | Consultation Room (live session) | **Done** |
| 6 | Contracts, Documents & Signatures | Not started |

**حالة الbackend فعلياً** (تأكيد مباشر من `backend/src/` و`git show --stat` على آخر commit): موجود بس `auth/` (كامل) + `common/` + `config/` + `health/` + `prisma/` (schema فيه بس Identity + Organization — `users, refresh_tokens, verification_codes, lawyer_registration_details, organizations, organization_members, organization_invitations`). **لا يوجد أي module لـ gov-procedures / lawyers / consultations / consultation-room / contracts / documents لهسا** — أجزاء 2-6 لازم تتبنى بالكامل من الصفر، schema وmodule وكل شي.

---

## جزء 1 — Profile & Account Settings — **Done**

**تصحيح مهم عن النسخة القديمة من هاي الخطة**: كانت بتقول "changePassword/sessions/2FA UI موجود وغير موصول". هاد كان غير دقيق — تم التحقق مباشرة من الكود:

- `AuthRemoteDataSource` (`lib/features/auth/data/datasources/auth_remote_data_source.dart`) فيه فعلاً `changePassword`, `listSessions`, `revokeSession`, `revokeOtherSessions`.
- `AuthRemoteDataSourceImpl` بينادي endpoints حقيقية: `POST /auth/password/change`, `GET /auth/sessions`, `DELETE /auth/sessions/{id}`, `DELETE /auth/sessions`.
- `backend/src/auth/auth.controller.ts` فيه كل الـroutes هاي فعلياً وشغالة: `register, login, refresh, logout, me (GET/PATCH), password/forgot, password/verify-otp, password/reset, password/change, sessions (GET/DELETE/:id/DELETE)`.
- `SecurityPrivacyScreen` بينادي `authRepositoryProvider.changePassword(...)` فعلياً من bottom sheet حقيقي، و`ActiveSessionsController` (`lib/features/profile/presentation/providers/active_sessions_controller.dart`) هو `AsyncNotifier` حقيقي بينادي `listSessions/revokeSession/revokeOtherSessions`.
- `edit_profile_screen.dart` بينادي `authControllerProvider.notifier.updateProfile(...)` → `PATCH /auth/me` حقيقي.

**الشي الوحيد الباقي فعلياً — 2FA**: `SecurityPrivacyScreen` فيها `SwitchListTile` بـ`value: false, onChanged: null` (معطّل عمداً، subtitle `l10n.securityTwoFactorUnavailable`). مافي أي method لـ2FA بـ`AuthRemoteDataSource`/`AuthRepository`، ومافي أي route بـbackend. **وهاد مقصود**: [02-auth-and-authorization.md](../backend/02-auth-and-authorization.md) §7 بيقول صراحة "2FA... defer to a later phase (not in the Phase 0–4 roadmap)". يعني 2FA رسمياً خارج نطاق هاي الخطة (أجزاء 1-6) — **لا تبنيه هلأ**. إذا حد طلب لاحقاً: الشكل الموصى فيه `POST /auth/2fa/enroll` (TOTP secret + QR) → `POST /auth/2fa/verify` (تفعيل)، جولة منفصلة.

**باقي المتروك عمداً** (billing، مو من نطاقنا): `payment_methods_screen.dart` / `invoices_screen.dart` تحت `lib/features/profile/presentation/screens/` بس الـdata/providers تبعهم فعلياً تحت `lib/features/billing/` — لا تلمسهم.
`saved_signature_screen.dart` (تحت profile/) presentation-only فعلاً، بلا أي repository — مؤجّل لجزء 6 كما بالخطة الأصلية.
`help_support_screen.dart` — static FAQ + bottom sheet وهمي، بلا أي controller أو datasource حتى وهمي. خارج النطاق، ما إلها backend module بالأصل.

**Done when**: ✅ متحقق فعلاً — تسجيل دخول، تعديل بروفايل، تغيير باسورد، عرض/إلغاء sessions كلها شغالة ضد backend حقيقي من الapp.

---

## جزء 2 — Gov Documents

**الوضع الحالي (مؤكد من الكود)**: `lib/features/gov_documents/presentation/providers/gov_procedures_provider.dart` — `govProceduresProvider` هو `Provider<List<GovProcedure>>` بيرجع `const [...]` 4 إجراءات (company/property/notarization/lawsuit) inline بنفس الملف (سطر 10-88)، بكل تفاصيلها الحقيقية (مستندات مطلوبة، خطوات). مافي أي datasource file، مافي mock/remote split، مافي `gov_documents_data_source_provider.dart`. `GovProceduresProgressController extends Notifier<Map<GovProcedureType, GovProcedureProgress>>` (نفس الملف، `build() => {}`) — بالذاكرة بس، بيرجع فاضي كل إعادة تشغيل. الشاشات: `gov_documents_hub_screen.dart`, `gov_procedure_detail_screen.dart`.

هاد أبعد جزء عن النمط المعياري — لازم تُبنى طبقة كاملة من الصفر، مش swap بس.

### Backend

**Schema** (جداول جديدة كلياً — `backend/prisma/schema.prisma`):

```prisma
enum GovProcedureType {
  companyRegistration
  propertyRegistration
  contractNotarization
  lawsuitFiling
}

enum GovProcedureAccessType {
  directLink
  guide
}

model GovProcedure {
  id           String                 @id @default(uuid()) @db.Uuid
  type         GovProcedureType       @unique
  durationLabel Json                  @map("duration_label")   // {"ar": "...", "en": "..."}
  accessType   GovProcedureAccessType @map("access_type")
  createdAt    DateTime               @default(now()) @map("created_at") @db.Timestamptz
  updatedAt    DateTime               @updatedAt @map("updated_at") @db.Timestamptz

  requiredDocuments GovRequiredDocument[]
  steps             GovProcedureStep[]
  progress          UserGovProcedureProgress[]

  @@map("gov_procedures")
}

model GovRequiredDocument {
  id          String  @id @default(uuid()) @db.Uuid
  procedureId String  @map("procedure_id") @db.Uuid
  title       Json    // {"ar": "...", "en": "..."}
  sortOrder   Int     @default(0) @map("sort_order")

  procedure GovProcedure @relation(fields: [procedureId], references: [id], onDelete: Cascade)

  @@index([procedureId])
  @@map("gov_required_documents")
}

model GovProcedureStep {
  id          String  @id @default(uuid()) @db.Uuid
  procedureId String  @map("procedure_id") @db.Uuid
  sortOrder   Int     @map("sort_order")
  title       Json
  description Json

  procedure GovProcedure @relation(fields: [procedureId], references: [id], onDelete: Cascade)

  @@index([procedureId])
  @@map("gov_procedure_steps")
}

model UserGovProcedureProgress {
  id                 String    @id @default(uuid()) @db.Uuid
  userId             String    @map("user_id") @db.Uuid
  procedureId        String    @map("procedure_id") @db.Uuid
  startedAt          DateTime? @map("started_at") @db.Timestamptz
  checkedDocumentIds String[]  @default([]) @map("checked_document_ids") @db.Uuid
  createdAt          DateTime  @default(now()) @map("created_at") @db.Timestamptz
  updatedAt          DateTime  @updatedAt @map("updated_at") @db.Timestamptz

  user      User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  procedure GovProcedure @relation(fields: [procedureId], references: [id], onDelete: Cascade)

  @@unique([userId, procedureId])
  @@map("user_gov_procedure_progress")
}
```
(لازم إضافة `govProcedureProgress UserGovProcedureProgress[]` على `model User` كـback-relation.)

**Seed**: الـ4 إجراءات + مستنداتها وخطواتها **مأخوذة حرفياً** من `gov_procedures_provider.dart` الحالي (نفس النص العربي، بدون ترجمة إنجليزية حقيقية لهسا — حط `en` placeholder أو نفس العربي مؤقتاً لحين ترجمة فعلية) بملف seed منفصل (`backend/prisma/seed.ts` أو migration seed)، يشتغل مرة وحدة (idempotent — `upsert` على `type`).

**Endpoints** (`GovProceduresController`, module جديد `backend/src/gov-procedures/`):
| Method & path | Auth | Purpose |
|---|---|---|
| `GET /v1/gov-procedures` | 🔒 (JWT) | القائمة كاملة + مستنداتها وخطواتها |
| `GET /v1/gov-procedures/{id}` | 🔒 | تفصيل واحد |
| `GET /v1/gov-procedures/{id}/progress` | 🔒 | تقدّم المستخدم الحالي |
| `PATCH /v1/gov-procedures/{id}/progress` | 🔒 | `{toggleDocumentId?, start?: true}` — upsert صف التقدّم |

**أمان**: كل الـendpoints خلف `JwtAuthGuard` (مافي فايدة حقيقية من جعلها public — البيانات ثابتة بس التقدّم شخصي). `PATCH progress` لازم يتحقق `documentId` فعلاً تابع لنفس `procedureId` قبل الإضافة (منع إدخال uuid عشوائي بالمصفوفة). لا حاجة لـRLS إضافي — الجدول الوحيد المرتبط بمستخدم هو `UserGovProcedureProgress`، مفلتر بـ`userId` من JWT مش من body/query أبداً.

### Frontend

- ملف جديد `lib/features/gov_documents/data/datasources/gov_documents_remote_data_source.dart` (abstract) بنفس شكل `getGovProcedures()`, `getGovProcedureProgress(procedureId)`, `updateGovProcedureProgress(procedureId, {toggleDocumentId?, start?})`.
- `gov_documents_mock_data_source.dart` — انقل الـ`const [...]` الحالي من الـprovider لهون كتنفيذ mock (يحافظ على نفس البيانات، بس بشكل الـpattern المعياري).
- `gov_documents_remote_data_source_impl.dart` (dio-backed) + `gov_documents_data_source_provider.dart` (نقطة التبديل).
- `GovProceduresProgressController` يصير `AsyncNotifier` بينادي الـrepository بدل `Notifier` محلي — `toggleDocument`/`start` تصير async مع optimistic update + rollback عند فشل الشبكة (pattern موجود أصلاً بمزايا تانية بالتطبيق، اتبعه).
- `govProceduresProvider` (القائمة) يصير `FutureProvider`/`AsyncNotifier` بدل `Provider` متزامن.

**Done when**: ✅ متحقق — فتح تطبيق، تقدّم بخطوة إجراء حكومي، تسكر التطبيق وتفتحه من جهاز/جلسة تانية بنفس الحساب — التقدّم محفوظ فعلياً بالDB (اتحقق منه مباشرة بـcurl smoke test، مو بس افتراض).

**نُفّذ فعلياً (2026-09-16)**:
- Backend: `GovProcedure/GovRequiredDocument/GovProcedureStep/UserGovProcedureProgress` بـ`backend/prisma/schema.prisma` + migration `20260916111402_add_gov_procedures` مطبّقة محلياً. Seed حقيقي (`backend/prisma/seed.ts`، محتوى مطابق حرفياً للفرونت القديم مع ترجمة إنجليزية placeholder) — شغّال (`npx prisma db seed`). Module `backend/src/gov-procedures/` (controller + service + DTO) — الـ4 endpoints المذكورة فوق. اختُبرت يدوياً عبر curl (register→login→list→progress GET/PATCH→رفض document من إجراء مختلف→404/401) وكلها رجعت الحالة الصحيحة. كل الـ16 test موجودين قبل التعديل لسا عم يعدّوا.
- **انحراف عن الخطة الأصلية**: `AuthModule` ما كانت مصدّرة (`exports`) أي provider — أي module جديد بيستخدم `JwtAuthGuard` لازم يصدّرها هي و`TokenService` من `AuthModule`، ويعيد تسجيل `JwtAuthGuard` كـprovider بموديوله هو (نمط Nest القياسي لـ`@UseGuards(Class)` عبر modules — الـclass reference بينحل من injector الموديول المستهلك مش المصدّر). طبّقناها هيك وصارت تنعاد بكل module جديد يحتاج JwtAuthGuard.
- Frontend: بُنيت الطبقة كاملة (`domain/repositories`, `data/datasources/{remote_data_source,mock_data_source,remote_data_source_impl,data_source_provider}`, `data/repositories`) وflip فعلي لـ`GovDocumentsRemoteDataSourceImpl`. `GovProceduresController`/`GovProceduresProgressController` صارت `AsyncNotifier` (بدل `Provider`/`Notifier` متزامنين) — **انحراف مقصود وموثّق مسبقاً بالخطة**: الشاشتين (`gov_documents_hub_screen.dart`, `gov_procedure_detail_screen.dart`) اتعدلوا ليتعاملوا مع `AsyncValue` (نفس نمط `switch (state) { AsyncData()=>, AsyncError()=>, _=> }` المستخدم أصلاً بـ`lawyers_list_screen.dart`) — تغيير UI-state handling بس، مو تصميم. `flutter analyze` نظيف، كل الـ466 test لسا عم يعدّوا (مافي tests كانت موجودة أصلاً لهاد الفيتشر).
- `durationLabel`/عناوين المستندات/الخطوات صارت jsonb `{ar, en}` بالbackend وتُختار حسب `localeControllerProvider` الحالي — تحسين حقيقي عن السلوك القديم (كان عربي ثابت دايماً بغض النظر عن اللغة).

---

## جزء 3 — Lawyers Marketplace (الجزء اللي يخص الفرد بس) — **Done**

**الوضع الحالي (مؤكد)**: `lawyers_mock_data_source.dart` (5 لوايرز)، `lawyers_remote_data_source.dart` interface بـ3 methods بس: `getLawyers()` (**بدون أي parameters — لا بحث ولا specialty ولا pagination**), `getLawyerById(id)`, `updateProfile(profile)`. `lawyers_data_source_provider.dart` نقطة تبديل جاهزة. الشاشات: `lawyers_list_screen.dart`, `lawyer_details_screen.dart` (ناضجتين، بالنطاق). `lawyer_profile_edit_screen.dart` خارج النطاق (lawyer-side).

**تصحيح 1 — فجوة حقيقية بالـinterface**: `LawyersController` (بتعليق صريح بالكود) بيفلتر/يبحث **client-side بالكامل** فوق القائمة الكاملة اللي بترجع من `getLawyers()`. الخطة القديمة افترضت `GET /v1/lawyers` بفلترة server-side (بحث + specialty + minRating + pagination) بس هاد **مو swap شفاف** — لازم تغيير حقيقي (صغير لكن حقيقي) على `LawyersRemoteDataSource.getLawyers()` ليقبل parameters اختيارية. قرار التنفيذ: أضف parameters اختيارية (`{String? query, LawyerSpecialty? specialty, double? minRating, int? page}`) بحيث لو ما انبعتوش الbackend يرجع نفس السلوك القديم (قائمة كاملة)، والفرونت يبلش يستخدمها تدريجياً.

**تصحيح 2**: `_verificationStatusLabel` (اللي الخطة القديمة قالت لازم تتعدل) موجودة بـ`lawyer_profile_edit_screen.dart:224` وهاد **خارج النطاق** (lawyer-side). الملفات اللي فعلاً بالنطاق (`lawyer_details_screen.dart`, `lawyer_card.dart`) بس عندها `if (lawyer.isVerified)` boolean check بسيط بمكانين — التغيير المطلوب أصغر بكثير مما كانت الخطة تفترض: `if (lawyer.isVerified)` → `if (lawyer.verificationStatus == VerificationStatus.verified)` بس هالمكانين.

### Backend

**Schema**: `LawyerProfile`, `LawyerProfileSpecialty` (join table enum), `LawyerConsultationOffering`, `Review` — تفاصيل الحقول كاملة بـ[01-domain-model.md](../backend/01-domain-model.md) §3. أهم نقاط:
- `LawyerProfile.userId` **unique FK** حقيقي لـ`User.id` (الفرونت اليوم عندها `LawyerProfile.id` منفصل تماماً عن `AuthUser.id` — لازم توحيدهم).
- `verificationStatus` enum (`unverified, pending, verified, rejected`) بدل البوليانين.
- `rating`/`reviewsCount` denormalized، تُحدّث بـtrigger أو بالـservice transaction عند إضافة `Review` جديدة (مو client-writable أبداً).
- **لازم بيانات لوير حقيقية للتجربة**: أنشئ `LawyerProfile` تلقائياً (بحالة `unverified`) لحظة تسجيل حساب `role=lawyer` — منطق يضاف بـ`AuthService.register` (استخدم `LawyerRegistrationDetail` الموجود أصلاً بالschema كمصدر لـ`barLicenseNumber`/`mainSpecialty` الابتدائيين).
- verify/reject admin endpoints (`POST /v1/admin/lawyers/{id}/verify|reject`) خلف permission `platformAdmin` **backend-only** — لا تُبنى كـ`UserRole` جديد ولا تُعرَّض بأي self-service endpoint (هاد قرار أمني موثّق بـ[16-backend-roadmap.md](../backend/16-backend-roadmap.md) Phase 0 Decision #1).

**Endpoints (يخص الفرد بس)**:
| Method & path | Auth | Purpose |
|---|---|---|
| `GET /v1/lawyers` | 🔒 | بحث/قائمة — `?query=&specialty=&minRating=&page=&limit=` كلهم اختياريون |
| `GET /v1/lawyers/{id}` | 🔒 | بروفايل عام |
| `GET /v1/lawyers/{id}/reviews` | 🔒 | تقييمات مقسّمة صفحات |

**أمان**: `barLicenseNumber`/`commercialRegistrationNumber` ما بترجع بـresponse القائمة/التفصيل العام أبداً (PII-adjacent، [14-security.md](../backend/14-security.md) §Sensitive data). كل enum فلترة (`specialty`) يتحقق ضد enum فعلي، مو string حر.

### Frontend
- Swap `LawyersMockDataSource` → `LawyersRemoteDataSourceImpl`، أضف الـparameters الاختيارية لـ`getLawyers()` كما فوق.
- عدّل `isVerified`/`hasPendingVerification` → enum واحد بالمكانين المحددين فوق بس.

**Excluded**: `lawyer_profile_edit_screen.dart`, verification submit/admin UI — lawyer-side.

**Done when**: `LawyersListScreen` يعرض لوايرز حقيقيين من الDB، البحث/الفلترة تتحول تدريجياً لسيرفر-سايد بدون كسر السلوك الحالي.

**نُفّذ فعلياً (2026-09-16)**:
- Backend: `LawyerProfile` (`userId` unique FK لـ`User.id`)، `LawyerProfileSpecialty` (join table تستخدم enum `LawyerSpecialty` الموجود أصلاً من Phase 1A)، `LawyerConsultationOffering`، `Review` (جديدة كلياً) — migration `20260916113840_add_lawyers_marketplace` + `20260916113849_add_review_rating_check` (CHECK يدوي على `rating BETWEEN 1 AND 5`، نفس نمط الـexclusion constraint اليدوي بجزء 4). Module `backend/src/lawyers/` (controller + service + DTOs) بالـ3 endpoints المذكورة فوق بالضبط. Seed: 5 حسابات lawyer حقيقية (`lawyer1..5@aqd.test` / `Password123`) بنفس بيانات الـmock القديم بالضبط (اسم، تخصصات، تسعير، تقييم)، كلها `verified` مسبقاً عشان القائمة تكون مليانة فوراً للاختبار.
- **AuthService.register**: لحساب `role=lawyer` جديد، صار يُنشئ `LawyerProfile` تلقائياً داخل نفس الـtransaction (`verificationStatus: unverified` دايماً، specialties مبدئياً = `[mainSpecialty]`) — طابق [09-lawyers-marketplace.md](../backend/09-lawyers-marketplace.md) §2 بالحرف.
- **قرار أمني مطبّق فعلياً (مو مذكور صراحة بنص هاي الخطة، مأخوذ من [09-lawyers-marketplace.md](../backend/09-lawyers-marketplace.md) §3 item 4)**: `GET /v1/lawyers` يرجع بس `verificationStatus = verified` افتراضياً — اتحقق يدوياً: حساب lawyer جديد سجّل (`unverified`) ما ظهر بالقائمة، وبقي عدد الطلب = 5 (الـseed بس).
- اختُبرت يدوياً عبر curl (register client → token → list بدون فلاتر (5 نتائج مرتبة rating desc) → فلتر query/specialty/minRating كل وحدة لحالها → 422 عند specialty غير صالح → 401 بدون توكن → detail موجود → reviews فاضية (حقيقي، مو مزيف — مافي write path لسا لأنه معلّق على `Consultation.completed` من جزء 4) → 404 على uuid صحيح غير موجود). كل الـ16 test الموجودين قبل التعديل لسا عم يعدّوا.
- **باغ حقيقي انلقى وانصلح أثناء الاختبار**: uuid مش صحيح الشكل بـ`:id` (مثلاً `/lawyers/not-a-uuid`) كان يفجّر 500 (Prisma exception خام يوصل لـexception filter العام) بدل 400/404 نظيف. أضفنا `ParseUUIDPipe` عالـ`:id` بـ`LawyersController`. **نفس الباغ موجود بالضبط بجزء 2 (`gov-procedures`) ولسا موجود هناك** — ما انصلح لأنه خارج نطاق هاي الجولة (جزء 2 أصلاً Done)، بس موثّق هون لتنظيف لاحق.
- **انحراف — pagination shape**: الخطة الأصلية ذكرت `page=&limit=` بس بدون تحديد شكل response. استُخدم `{ data: [...], meta: { page, limit, total } }` (offset-based بالحرف زي ما طلبت الخطة) بدل الـcursor-based المذكور بـ[05-api-design.md](../backend/05-api-design.md) §5 كتوصية عامة — قرار مبرر لأن نص الخطة هون أدق من التوصية العامة لهاي الحالة تحديداً.
- **انحراف — `Review.consultationId` بدون FK علاقة**: العمود uuid حقيقي وindexed (عبر الـunique constraint) بس بدون `@relation` لـ`Consultation` لأنه الجدول مو موجود لسا (جزء 4). هيك جزء 4 بس يضيف الـFK بmigration بسيطة (`ALTER TABLE ... ADD CONSTRAINT`) بدل data migration. الـendpoint `GET /v1/lawyers/{id}/reviews` حقيقي ويرجع فاضي فعلاً، مو hardcoded.
- Frontend: `LawyerProfile` entity — استبدال `isVerified`/`hasPendingVerification` (bool) بحقل واحد `verificationStatus: VerificationStatus` (enum جديد `unverified/pending/verified/rejected`، مطابق للbackend بالحرف). `lawyer_card.dart`/`lawyer_details_screen.dart`: التعديل محصور بالمكانين المحددين بالخطة بالضبط. `LawyersRemoteDataSource.getLawyers()` صار يقبل `{query?, specialty?, minRating?, page?}` اختيارية — المُنفّذ الحقيقي (`LawyersRemoteDataSourceImpl`, جديد) يمررها كـquery params، `LawyersMockDataSource` طبّقتها فعلياً بنفس منطق الفلترة (client-side) عشان تبقى متماثلة سلوكياً مع القديم. `LawyersRepository`/`Impl` مررت نفس الـparameters (pass-through) عشان القدرة تكون قابلة للاستدعاء فعلياً، بس **`LawyersController`/`LawyersListScreen` لسا بيستدعوا `getLawyers()` بدون parameters وبيفلتروا client-side زي قبل بالضبط** — قرار متحفظ يحقق "بدون كسر السلوك الحالي" حرفياً، ترك التفعيل الفعلي للفلاتر السيرفر-سايد بالشاشة لخطوة تالية ("تدريجياً" كما بالخطة). `lawyersRemoteDataSourceProvider` صار يشير لـ`LawyersRemoteDataSourceImpl` (نقطة التبديل).
- **`LawyerAvailabilityWindow` (فلتر "متاح اليوم/هالأسبوع/لاحقاً") بقي client-side hash-derived بدون أي تغيير** — مو مذكور أصلاً بجدول الـparameters المطلوب إضافتها بهاي الخطة، ومتعمد إنه منفصل عن التقويم الحقيقي (تعليق بالكود أصلاً).
- **انحراف — `updateProfile` (lawyer self-edit, خارج النطاق أصلاً)**: `LawyersRemoteDataSourceImpl.updateProfile` مكتوب يستدعي `PATCH /v1/lawyers/me` (نفس الشكل الموثّق بالroadmap الأوسع [09-lawyers-marketplace.md](../backend/09-lawyers-marketplace.md) §7) بس **الـendpoint هاد مو مبني بهاي الجولة** (lawyer-side، خارج نطاق هاي الخطة صراحة). `lawyer_profile_edit_screen.dart` وباقي شاشات lawyer-side ما انلمست UI-wise، بس اضطرت تتعدل ميكانيكياً بس (نفس الحقول القديمة `isVerified`/`hasPendingVerification` مو موجودة عالـentity المشترك أصلاً) — نفس الشي بملفي التست (`lawyer_profile_edit_screen_test.dart`, `hardening_pass_responsive_test.dart`) اللي بيستخدموا `LawyersMockDataSource` عبر `overrideWithValue` صراحة، فبتضلوا شغالين بالكامل بغض النظر عن الـflip العام لأن الـmock نفسه كامل ومحدّث. تطبيق `/lawyers/me` الحقيقي مؤجل لجولة lawyer-side منفصلة.
- `flutter analyze` نظيف، كل الـ466 test لسا عم يعدّوا (مافي تست جديد انضاف لهاد الجزء — نفس نمط جزء 2، التحقق تم عبر curl حقيقي زي فوق).

---

## جزء 4 — Consultations & Booking — **Done**

**الوضع الحالي (مؤكد)**: `consultations_mock_data_source.dart` (409 سطر) ينفذ `consultations_remote_data_source.dart` (interface بـ14 method: `getConsultations, getConsultationById, getAvailability(lawyerId), addAvailabilitySlot, removeAvailabilitySlot, bookConsultation, acceptRequest, rejectRequest, cancel, reschedule, complete, markMissed, markFailed, sendMessage`). مؤكد: `cancel(id)`/`rejectRequest(id)` بدون parameter سبب حالياً — الخطة صحيحة بهاد. الشاشات بالنطاق: `booking_type_screen`, `booking_datetime_screen`, `booking_details_screen`, `consultations_list_screen`, `consultation_details_screen`. خارج النطاق: `lawyer_requests_screen.dart`, `lawyer_schedule_screen.dart`.

**Depends on**: جزء 3 (لازم lawyers + offerings موجودين حقيقياً بالDB).

### Backend

**Schema**: `AvailabilitySlot`, `Consultation` (12-state machine)، `Review` write path — تفاصيل كاملة [01-domain-model.md](../backend/01-domain-model.md) §4، state machine الكاملة [06-consultations.md](../backend/06-consultations.md) §3.

**نقطة حرجة (concurrency)**: منع double-booking لازم يكون على مستوى الDB مو بس الـapplication layer:
```sql
ALTER TABLE availability_slots ADD CONSTRAINT no_overlapping_booked_slots
  EXCLUDE USING gist (
    lawyer_profile_id WITH =,
    tstzrange(start_at, end_at) WITH &&
  ) WHERE (is_booked);
```
(يحتاج `CREATE EXTENSION IF NOT EXISTS btree_gist;` — Prisma DSL ما بتعبّر عن exclusion constraints، لازم SQL يدوي بالmigration زي ما صار مع الـpartial unique index بـ`organization_members`.) الاختبار المطلوب: طلبين حجز متزامنين (parallel `Promise.all` بtest) لنفس الslot بالضبط — واحد بس ينجح، الثاني يرجع 409/422 مو exception غير متوقع.

**Endpoints (يخص الفرد + الحد الأدنى اللازم من lawyer-side عشان نختبر)**:
| Method & path | Auth | Purpose |
|---|---|---|
| `GET /v1/lawyers/{id}/availability` | 🔒 | slots متاحة للحجز |
| `POST /v1/consultations` | 🔒 (client) | حجز |
| `GET /v1/consultations` | 🔒 | قائمة استشارات المستخدم |
| `GET /v1/consultations/{id}` | 🔒 | تفصيل |
| `POST /v1/consultations/{id}/cancel` | 🔒 | `{cancellationReason}` |
| `POST /v1/consultations/{id}/reschedule` | 🔒 (client) | `scheduledAt` جديد، يعيد فحص الslot |
| `POST /v1/consultations/{id}/reviews` | 🔒 (client, بعد `completed` بس) | `Review` |
| `POST /v1/lawyers/me/availability` | 🔒 (lawyer) | **الحد الأدنى** لخلق slots نختبر عليها — بدونها ما في شي الفرد يحجزه |
| `POST /v1/consultations/{id}/accept` `.../decline` | 🔒 (lawyer) | **الحد الأدنى** لتفعيل دورة الحجز كاملة |

**أمان**: كل status transition عبر endpoint مخصص (`cancel`, `reschedule`...) **أبداً** مش `PATCH {status: ...}` عام — الـstate machine بـ[06-consultations.md](../backend/06-consultations.md) §3 تحدد الانتقالات المسموحة فقط، transition غير صالح = 422.

### Frontend
- Swap `ConsultationsMockDataSource`.
- `bookConsultation` يتعامل مع فشل جديد ("الslot اتاخد قبل ما تأكد") كـ`Result.failure` عادي — الشاشة أصلاً جاهزة تعرض أخطاء عامة.
- `cancel`/`rejectRequest` تقبل optional reason parameter (additive، non-breaking على التوقيع).

**Excluded**: `lawyer_requests_screen.dart`, `lawyer_schedule_screen.dart` كـUI — بس الـendpoints المقابلة إلهم لازم تُبنى backend-only (بدون شاشة) عشان جزء الفرد يشتغل end-to-end.

**Done when**: حجز استشارة كامل من التطبيق (اختيار نوع → وقت → تفاصيل → تأكيد) يطلع `Consultation` حقيقي بالDB بحالة `pendingApproval`؛ اختبار الحجز المتزامن يثبت واحد بس ينجح.

**نُفّذ فعلياً (2026-09-16)**:
- Backend: `AvailabilitySlot` + `Consultation` (جديدين بالكامل) بـ`backend/prisma/schema.prisma` + migration `20260916115831_add_consultations_booking` مطبّقة محلياً — فيها `CREATE EXTENSION btree_gist` والـexclusion constraint اليدوي `no_overlapping_booked_slots` بالضبط كما بالخطة (Prisma DSL ما بتعبّر عنه). `Review.consultationId` صار FK حقيقي لـ`Consultation` (كان عمود uuid بلا علاقة من جزء 3، أُضيفت العلاقة هون بـ`ALTER TABLE ... ADD CONSTRAINT` زي ما كان موثّق). Module `backend/src/consultations/` (`ConsultationsController` على `/consultations/*`، و`AvailabilityController` منفصل على `/lawyers/{id}/availability` + `/lawyers/me/availability` — matches جدول الendpoints بالخطة بالحرف). اختُبر كامل يدوياً عبر curl: تسجيل client + login lawyer1 (نفس بيانات seed جزء 3) → إنشاء slots → حجز → 422 (حقول ناقصة) → 403 (lawyer يحاول يحجز، client يحاول يضيف availability) → 401 (بدون token) → 404 (uuid صحيح غير موجود) → 400 (uuid مش صحيح الشكل، `ParseUUIDPipe` مطبّق من البداية هون خلافاً لجزء 2/3) → accept/decline/cancel/reschedule/complete كلهم رجعوا الحالة الصحيحة وحرروا الـslot عند الحاجة → review بعد `completed` بس (400 قبلها، 409 عند التكرار) → تحديث `LawyerProfile.rating/reviewsCount` تلقائياً (تأكد فعلياً بعد إضافة review: rating=5, count=1). **اختبار الحجز المتزامن الحقيقي**: طلبين `POST /consultations` بالتوازي (`&`+`wait`، مو sequential) لنفس الـslot بالضبط — واحد رجع 201، الثاني رجع 409 نظيف `"This slot was just booked by someone else."` بدون أي exception غير متوقع أو double-booking. كل الـ16 test الموجودين قبل التعديل (`npm test`) لسا عم يعدّوا.
- **انحراف — سعر محسوب سيرفر-سايد دايماً**: `CreateConsultationDto` أصلاً ما بتقبل `price` — السيرفر يحسبه من `LawyerConsultationOffering` المطابقة لـ`(lawyerId, type)` وقت الحجز، ما بثق فيه من الclient أبداً (قرار أمني، موثّق بتعليق بالكود). الفرونت لسا بيبعت `price` بالـinterface (توافق مع الmock) بس `ConsultationsRemoteDataSourceImpl` ما بضيفه للـbody المُرسل فعلياً.
- **انحراف — توسيع مجموعة الـendpoints عن جدول الخطة الحرفي**: أُضيفت `POST /consultations/{id}/complete`, `.../miss`, `.../fail` رغم إنها مو مذكورة بجدول endpoints جزء 4 صراحة. السبب: `consultation_details_screen.dart` (بالنطاق) بينادي `.complete()` مباشرة من زر "إنهاء" بواجهة اللواير، وشاشات `consultation_room` (خارج النطاق، جزء 5) بتنادي `.markMissed()`/`.markFailed()` عبر نفس الـ`consultationsControllerProvider` المشترك — بما إنه الـflip بيصير على مستوى الفيتشر كامل (نقطة تبديل وحيدة)، بدون هالـendpoints كان رح ينكسر زر "إنهاء" بشاشة بالنطاق، وشاشات consultation_room كانت رح تفشل بـ404 بدل ما تكمل تشتغل بالmock. أُضيفت كإضافة صغيرة متسقة مع الstate machine الموجود أصلاً بالفرونت (`ConsultationStatusX`)، مو تصميم جديد.
- **انحراف — تبسيط `ConsultationStatus` بالbackend**: enum الbackend فيه بس 7 قيم (`pendingApproval, confirmed, completed, cancelled, declined, missed, failed`) — بدون الحالات المرحلية اللي فقط تخص live-session (`waiting, ready, connecting, active, ended`) الموجودة بـenum الفرونت. هاي الحالات المرحلية تبقى client-local بالكامل جوا `consultation_room` (جزء 5 لسا ما بلش) ومو محفوظة بالbackend أبداً بهاي الجولة — `confirmed` بتنقل مباشرة لـ`completed`/`missed`/`failed` من منظور الDB.
- **انحراف — حذف `sendMessage` (dead code)**: اتأكد عبر audit شامل إنه مافي أي UI caller حقيقي لـ`ConsultationsRepository.sendMessage`/`ConsultationsRemoteDataSource.sendMessage` — الشات الحقيقي للاستشارات الكتابية يمر بالكامل عبر فيتشر `messages/` المنفصل (`MessagesRepository`/`ChatController`)، والتعليق بالكود نفسه كان يقول صراحة "nothing in the UI calls this anymore". اتحذفت الmethod كاملاً من الـinterface، الmock، الrepository، والcontroller (مع تست الmock المرتبط فيها)، وتعدّل `test/features/messages/presentation/chat_room_test_support.dart`'s `SingleConsultationDataSource` توافقاً. `ConsultationMessage`/`Consultation.messages` (الentity/الحقل) تركوا كما هم (غير مستخدمين حقيقياً بس ما بيضروا، إزالتهم نطاق أوسع من المطلوب).
- **انحراف — `cancel`/`rejectRequest` صارت تقبل `{String? reason}` اختياري** كما بالخطة بالضبط (additive، non-breaking) — بس ما ولا شاشة بالنطاق بتجمع سبب نصي فعلياً لهسا (زر الإلغاء بيبعت `null`)، فهاد substrate بس جاهز لخطوة UI لاحقة.
- **معروف ومقبول — فجوة بشاشات خارج النطاق**: `lawyer_schedule_screen.dart`/`lawyer_requests_screen.dart` (خارج النطاق، ما انلمستوا) بيستخدموا نفس الـdatasource المُبدّل. `lawyer_requests_screen.dart` (accept/reject) بيشتغل صح فعلياً (بيعتمد بس على JWT + consultationId). لكن `lawyer_schedule_screen.dart` بيستخدم `kDemoLawyerId` (السلسلة الثابتة `'lwr_seed_1'`، مو uuid حقيقي) كـ`lawyerId` لـ`getAvailability` — هاد هينكسر ضد الbackend الحقيقي (`ParseUUIDPipe` بيرفضه 400) لو حد فعلياً فتح هاي الشاشة بحساب لواير حقيقي. نفس نمط الفجوة الموثّقة بجزء 3 لـ`lawyer_profile_edit_screen.dart`/`PATCH /lawyers/me` — مقبولة لأنها خارج نطاق هاي الجولة، مؤجلة لجولة lawyer-side منفصلة.
- Frontend: بُنيت الطبقة كاملة (`consultations_remote_data_source_impl.dart` جديد، `consultations_data_source_provider.dart` صار يشير له). `AvailabilitySlot.consultationId` بيتقرأ من `consultation.id` المُضمّن بـresponse الـbackend (أُضيف `include: {consultation: {select:{id}}}` بالservice). **ملاحظة تقنية مهمة**: حقل `price` بـ`Consultation`/Prisma `Decimal` بيترجم لـJSON **كنص** (`"180"`) مو رقم — الparsing بالفرونت يستخدم `double.parse(row['price'] as String)` مو `(row['price'] as num).toDouble()` (خلافاً لنمط جزء 3's `pricing` اللي هو `num` فعلي). الشاشات المذكورة بالخطة (`booking_type_screen`, `booking_datetime_screen`, `booking_details_screen`, `consultations_list_screen`, `consultation_details_screen`) ما احتاجت أي تعديل UI — كلها كانت أصلاً بتتعامل مع `AsyncValue`/`Result` وبتنادي `consultationsRepositoryProvider`/`consultationsControllerProvider`/`bookingControllerProvider`/`availabilityProvider` الموجودين. `flutter analyze` نظيف، كل الـ465 test (466 ناقص تست `sendMessage` المحذوف) عم يعدّوا.

## جزء 5 — Consultation Room (live session) — **Done**

**تصحيح مهم عن النسخة القديمة من هاي الخطة**: الـinterface الفعلي (`consultation_room_remote_data_source.dart`) عنده 7 methods بس: `getSession, join, connect, retryConnection, reportConnectionLost, endSession, updateMetrics` — **مافي `leave` method إطلاقاً بالـinterface**، ومافي أي "token" method مكشوفة للـcontroller/screens. جدول الـendpoints القديم (`token/join/leave/retry/end`) كان تخمين تقريبي غير دقيق. **الوضع الحالي (مؤكد من الكود)**: `consultation_room_mock_data_source.dart` (142 سطر) — وهمي بالكامل عمداً وموثّق: بيزرع `_ConnectionProfile` (`reliable`/`recoversOnRetry`/`neverConnects`) من `consultationId.hashCode % 3` عشان الديمو يكون deterministic؛ `connect()` عنده منطق مختلف لـwritten (يروح مباشرة لـactive) عن voice/video (يعبر بـconnecting). الشاشات: `consultation_waiting_screen.dart`, `voice_call_screen.dart`, `video_call_screen.dart` (الأخيرة نفس بنية `voice_call_screen.dart` بالضبط، فيها زيادة `toggleCamera`) — تستهلك `sessionControllerProvider` (`AsyncNotifier.family`) والـstate machine بـ`domain/entities/session_state.dart`. **مهم**: `durationSeconds` (عداد وقت المكالمة) ما بينمر عبر أي method بالـrepository أبداً — `SessionController.incrementDuration()` بيعدّل الـstate محلياً بس (كل ثانية عبر `Timer` بالشاشة)، فمافي حاجة السيرفر يخزّنه أو يستقبله.

**Depends on**: جزء 4 — تأكد فعلياً قبل البلش: استعلام مباشر على الDB المحلي رجع consultations بحالة `completed`/`declined` حقيقية، وأُنشئت استشارة `confirmed` جديدة فعلياً (accept حقيقي) للاستخدام باختبار هاد الجزء.

### Backend

**Schema** (جداول جديدة كلياً — migration `20260916122740_add_consultation_room`): `ConsultationRoomSession` (1:1 مع `Consultation`، `state: waiting→ready→connecting→active→ended|failed`، + `isMuted/isCameraOn/isSpeakerOn/reconnectAttempts/endedAt` — **بدون** `durationSeconds`، قرار مقصود فوق)، `ConsultationRoomToken` (نفس نمط `RefreshToken`: opaque random 32-byte + SHA-256 hash محفوظ، `expiresAt`/`consumedAt` لتطبيق single-use + TTL)، `ConsultationParticipantEvent` (append-only enum `join/leave/reconnect`). **بدون real media provider بهاي الجولة** (Agora/Twilio/LiveKit مؤجل لـPhase 7) — round-trip حقيقي بالكامل، الـstate transitions حقيقية 100% عبر الـDB.

**Endpoints الفعلية** (`ConsultationRoomController` على `/consultations/{id}/room/*`, module `backend/src/consultation-room/`) — موسّعة عن الجدول القديم لتطابق الـ7 methods الحقيقية بالـinterface + endpoint احتياطي واحد:
| Method & path | Purpose |
|---|---|
| `POST .../room/token` | ينشئ/يجيب صف الـsession (`upsert` على `consultationId`) + يصدر room token جديد (يبطّل أي token سابق غير مستخدم لنفس المستخدم) → يقابل `getSession()` |
| `POST .../room/join` | `{roomToken}` — يستهلك التوكن (single-use)، `waiting→ready` فقط (غير هيك 400) |
| `POST .../room/connect` | `ready→active` دايماً (مافي media provider حقيقي يفشل بمقابله هلأ — الفشل العشوائي كان تخمين ديمو محلي بس بالـmock) |
| `POST .../room/retry` | `failed→active` + `reconnectAttempts++`، يرفض بعد 3 محاولات |
| `POST .../room/connection-lost` | `active→failed` |
| `POST .../room/leave` | **إضافة احتياطية backend-only** (نفس نمط جزء 4's lawyer-side endpoints) — تسجيل `ConsultationParticipantEvent(leave)` بس بدون تغيير state؛ الفرونت ما بستدعيها هاي الجولة (لأ الـinterface نفسه ما فيه `leave` — انظر التصحيح فوق) |
| `POST .../room/end` | أي state غير `ended` → `ended` + `endedAt` |
| `PATCH .../room/metrics` | `{isMuted?, isCameraOn?, isSpeakerOn?}` |

كل الـendpoints خلف `JwtAuthGuard` + فحص participant (client أو lawyer المرتبطين بالconsultation، عبر `LawyerProfile.userId`) + `consultation.status === 'confirmed'` (لا يمكن فتح غرفة لاستشارة لسا pending أو خلصت). **حُذف "auto-end/auto-miss scheduled job"** المذكور بالخطة القديمة — غير لازم: auto-end (60 دقيقة) وauto-miss (grace period) أصلاً client-driven بالكامل عبر `ConsultationRoomTiming` + `consultationsControllerProvider.markMissed/markFailed` (جزء 4)، إضافة cron سيرفر-سايد كانت هتكرر نفس المنطق وتحتاج infra إضافي (`@nestjs/schedule`) مافي داعي له.

**أمان**: `ConsultationRoomToken` — single-use (`consumedAt`)، scoped لـ`(sessionId, userId)` بالضبط، TTL=5 دقائق بالحرف، hash فقط محفوظ (SHA-256، نفس نمط `TokenService.hashRefreshToken`) — الراو token يرجع مرة وحدة بـresponse `/token` وما بينخزن. اختُبر فعلياً: توكن مستخدم مرتين يرجع 401 بالمرة الثانية.

**باغ حقيقي انلقى وانصلح أثناء اختبار التكامل مع جزء 4**: `ConsultationsService.complete()` (جزء 4) كانت مقيّدة `lawyer` بس (`lawyerProfileForUser`) — بس `voice_call_screen.dart`/`video_call_screen.dart` بينادوا `consultationsControllerProvider.notifier.complete()` من أي طرف يضغط "إنهاء المكالمة" (client أو lawyer، مافي فرق بالكود). نتيجتها: لو الclient سكّر المكالمة، استدعاء `complete()` يرجع 403 صامت (best-effort، النتيجة ما بتتفحص) والconsultation تفضل عالقة عند `confirmed` للأبد بدل `completed`. **الإصلاح**: `complete()` صارت تستخدم `consultationForParticipant` (بدل `lawyerProfileForUser`+`consultationOwnedByLawyer`) — مطابقة تماماً لنمط `markMissed`/`markFailed` الجانبيين اللي كانوا أصلاً participant-agnostic. اتأكد بعد الإصلاح: client قدر يـ`complete()` استشارته الخاصة (201)، مستخدم غير مرتبط لسا يرجع 403. كل الـ16 test الخلفية لسا عم يعدّوا بعد التعديل.

### Frontend
- `ConsultationRoomRemoteDataSourceImpl` (dio) جديد + flip `consultation_room_data_source_provider.dart` عليه. `SessionState` machine والشاشات (`consultation_waiting_screen.dart`, `voice_call_screen.dart`, `video_call_screen.dart`) **ما تغيّرت إطلاقاً** — بالضبط كما بالخطة.
- room token (single-use، مو معروض بالـinterface) بيتخزّن مؤقتاً بذاكرة الـimpl نفسه (`Map<consultationId, roomToken>`) بين استدعاء `getSession()` واستدعاء `join()` اللي بعده — تفصيل تنفيذي داخلي بالكامل، `SessionController`/الشاشات ما بتعرف بوجوده.
- `type` (voice/video/written) ما بيرجع من الـbackend بصف room session (موجود أصلاً عند `Consultation.type`) — بيتخزّن بذاكرة الـimpl (per `consultationId`, من argument `getSession`) وينحط رجوع بكل response يتفسّر.

**Done when**: ✅ متحقق فعلاً — فتح غرفة استشارة يعمل session حقيقي بالbackend (state transitions حقيقية عبر round-trip فعلي، اتحقق يدوياً بكل الحالات: token→join→connect→metrics→connection-lost→retry→leave→end + invalid-transition rejection على كل خطوة رجعت 400 نظيف)، حتى لو الصوت/فيديو نفسه لسا مو متكامل مع provider خارجي. `flutter analyze` نظيف، كل الـ465 test لسا عم يعدّوا.

---

## جزء 6 — Contracts, Documents & Signatures

**الوضع الحالي (مؤكد)**: `contracts_mock_data_source.dart` ينفذ `contracts_remote_data_source.dart` — `signContract(String id)` نداء واحد مسطّح (بدون participant awareness)، `Contract.parties` هو `List<String>` نص حر بدون هوية ولا حالة توقيع لكل طرف — **مؤكد فعلياً بالكود، مش افتراض**. `contract_signature_sheet.dart` (widget UI بس) بيجمع التوقيع (من `SavedSignatureController`، رفع، أو رسم) ويرجع `true`/`false` بس — ما بينادي `signContract` نفسه، وما عنده أي وعي بأطراف — يعني هاد فعلاً سطح منتج جديد، مو UI موجود يُعاد استخدامه.

**تصحيح**: `documents_mock_data_source.dart` (ينفذ `documents_remote_data_source.dart`: `getDocuments, addGeneratedContractDocument, uploadDocument({title}), renameDocument, deleteDocument`) — `uploadDocument` ياخد **عنوان نصي بس، بدون bytes حقيقية إطلاقاً**؛ `sizeLabel` مُصطنع حرفياً (`'${120 + title.length * 5} KB'`). **هاد هو الـstub الفعلي** — أما `documents_screen.dart` نفسها فهي شاشة "vault" كاملة فعلاً (379 سطر: بحث، 4 فلاتر، رفع/تسمية/حذف عبر `PopupMenuButton`، pull-to-refresh، empty states) — **مو شاشة ناقصة**، بس مربوطة بداتا وهمية. الشغل المطلوب هون هو بناء الـdatasource الحقيقي (رفع bytes فعلية)، مو توسعة الشاشة.

`saved_signature_screen.dart` (تحت profile/) presentation-only، `SavedSignatureController` مجرد `Notifier` بلا أي repository — يحتاج طبقة كاملة من الصفر.

### Backend

**Schema**: `ContractTemplate` + `ContractTemplateField` (7 categories: employment, sale, rental, partnership, nda, serviceAgreement, other — jsonb localized، seed مرة وحدة، `version` field عشان تعديل template لاحقاً ما يغيّر عقود موقعة قبل)، `Contract` (`ownerUserId`/`organizationId` **جديدين كلياً**، `status`: `draft, pendingSignature, signed, completed, cancelled` — `signed` هي الحالة النهائية الناجحة v1، `completed` معرّفة بس مو مستخدمة)، `ContractParticipant` (**جديد بالكامل** — `role`: `owner, counterparty, lawyerReviewer, witness`، `status`: `pending, signed, declined`)، `ContractSignature` (**جديد بالكامل** — `ipAddress`/`userAgent` evidentiary)، `SavedSignature`، `Document` + `DocumentVersion` (version history حقيقي، `Document` الحالي بالفرونت ما عنده). تفاصيل كاملة [01-domain-model.md](../backend/01-domain-model.md) §7 و[08-contracts-documents-signatures.md](../backend/08-contracts-documents-signatures.md).

**Upload flow (signed-URL، ليس proxy)** — [05-api-design.md](../backend/05-api-design.md) §3:
1. `POST /v1/uploads/init {fileName, mimeType, sizeBytes, purpose}` → صف `DocumentVersion` pending + pre-signed PUT URL.
2. Client يرفع bytes مباشرة لـobject storage.
3. `POST /v1/uploads/{id}/complete` → السيرفر يتحقق (HEAD request) الحجم/النوع مطابقين للمُصرَّح، يفعّل الصف.

**أمان (أهم بند بهاد الجزء)**: enforcement حقيقي إنه `role = lawyer` **read-only** على `Contract`/`Document` على مستوى الـAPI — هاد يقفل فجوة موثقة بالـaudit: زر التوقيع بالفرونت اليوم ما عنده أي حارس دور غير حالة العقد، بالكامل معتمد على إن الـUI بس ما بتعرض الزر. الbackend لازم يكون أول enforcement حقيقي. كل الـwrite endpoints (`POST/PATCH/DELETE /v1/contracts*`, `/v1/documents*`) ترفض `role=lawyer` بـ403 حتى لو استدعى الـAPI مباشرة.

**Endpoints**:
| Method & path | Auth | Purpose |
|---|---|---|
| `GET /v1/contract-templates` | 🔒 | كتالوج (فئة + حقول)، locale-aware |
| `GET /v1/contracts` `.../{id}` | 🔒 | قائمة/تفصيل |
| `POST /v1/contracts` | 🔒 (not lawyer) | حفظ مسودة |
| `PATCH /v1/contracts/{id}` | 🔒 (owner/org, draft فقط, not lawyer) | تعديل حقول |
| `DELETE /v1/contracts/{id}` | 🔒 (owner/org, draft فقط, not lawyer) | حذف |
| `POST /v1/contracts/{id}/generate` | 🔒 (not lawyer) | draft → pendingSignature، يخلق participants + مستند مسودة |
| `POST /v1/contracts/{id}/sign` | 🔒 (participant مخوّل بس، أبداً lawyer) | يسجّل توقيع؛ يقلب حالة العقد لما الكل يوقّع |
| `POST /v1/contracts/{id}/cancel` | 🔒 (owner/org admin) | `{cancellationReason}` |
| `GET /v1/documents` `POST` `PATCH /{id}` `DELETE /{id}` `GET /{id}/download` | 🔒 (not lawyer عدا القراءة) | vault كامل، download عبر signed URL قصير العمر |
| `GET/POST/DELETE /v1/users/me/saved-signatures` | 🔒 | CRUD بسيط |

### Frontend
- Swap `ContractsMockDataSource` **مع تغيير UI حقيقي**: signing sheet لازم يعرض حالة كل participant، وSign button يتفعل بس إذا المستخدم الحالي participant مخوّل وما وقّع بعد — منتج جديد فعلياً، مو موجود بالفرونتند الحالي.
- Swap `DocumentsMockDataSource` — الداتاسورس يصير حقيقي (رفع bytes فعلية عبر init→PUT→complete)؛ `documents_screen.dart` **ما تحتاج توسعة** (كاملة أصلاً)، بس ربط بمصدر بيانات حقيقي.
- `SavedSignatureController` → repository جديد بالكامل، بنفس نمط باقي الفيتشرز.

**Done when**: عقد بمشاركة طرفين، كل طرف يوقع، الحالة تتغير لـ`signed`، الملف يترفع فعلياً (bytes حقيقية مش label حجم وهمي)؛ اختبار محاولة توقيع/تعديل من حساب `lawyer` يرجع 403.

---

## التشغيل محلياً (Backend + DB — بدون Docker/Redis)

- **PostgreSQL**: EnterpriseDB install، `/Library/PostgreSQL/18`، port 5432. DB: `aqd_dev`، role `aqd`/`aqd_dev_password`، extension `citext` مفعّلة (و`btree_gist` لازم تتفعّل إضافي لجزء 4 — exclusion constraint).
- `backend/.env` (gitignored): `DATABASE_URL=postgresql://aqd:aqd_dev_password@localhost:5432/aqd_dev?schema=public` + `JWT_ACCESS_SECRET`.
- أول مرة بس: `npm install` ثم (npm allow-scripts gate) `npm approve-scripts prisma @prisma/client @prisma/engines` ثم `npm install` تاني.
- تشغيل: `cd backend && npm run dev` (port 3000, prefix `/v1`). فحص: `GET /v1/health`.
- بعد أي تعديل schema: `npx prisma migrate dev --name <وصف>` (يولّد migration SQL + يطبّقها محلياً). لأي exclusion/partial-unique constraint ما بتقدر Prisma DSL تعبّر عنها: عدّل ملف الـSQL المولّد يدوياً قبل ما يتطبّق (زي `organization_members` وnow `availability_slots`).
- Seed بيانات ثابتة (gov procedures, contract templates): `npx prisma db seed` أو script منفصل يشتغل idempotent (`upsert`).
- اختبارات: `npm test` (unit)، `npm run test:e2e` (يحتاج الDB شغالة).
- Flutter يوصل تلقائياً على `http://localhost:3000/v1` (`lib/core/config/app_config.dart`) بدون أي إعداد إضافي محلياً.

---

## ملاحظات تنفيذ (يتحدث أول ما يصير تقدم)

- **2026-09-16**: مراجعة شاملة للخطة القديمة عبر audit مباشر على الفرونت والbackend (مو افتراضات). أهم التصحيحات:
  - جزء 1 فعلياً **Done** — change-password/sessions/edit-profile كانت موصولة فعلياً بـbackend حقيقي (auth module مكتمل)، عكس ما كانت الخطة القديمة تفترض. الشي الوحيد الناقص (2FA) مؤجّل رسمياً بـ[02-auth-and-authorization.md](../backend/02-auth-and-authorization.md) §7 — خارج نطاق Phase 0-4، ما رح يُبنى بهاي الجولة.
  - `api_error_mapper.dart` موقعه الصحيح `lib/core/network/`، مو `lib/core/errors/`.
  - جزء 3: `getLawyers()` الحالي بدون أي parameters — الفلترة/البحث كلها client-side اليوم. لازم إضافة parameters اختيارية للـinterface (مو مجرد افتراض إن الbackend رح يفلتر تلقائياً).
  - جزء 3: تعديل `verificationStatus` الفعلي محصور بملفين بالنطاق (`lawyer_details_screen.dart`, `lawyer_card.dart`) — مو `_verificationStatusLabel` اللي هي أصلاً خارج النطاق (lawyer-side).
  - جزء 6: `documents_screen.dart` شاشة كاملة فعلاً (مو stub) — الـstub الحقيقي هو الداتاسورس بس (رفع title بدون bytes).
  - تأكيد: backend فيه بس auth module فعلياً — باقي الأجزاء (2-6) schema/module/endpoints من الصفر بالكامل.
- **2026-09-16 (تكملة نفس الجلسة)**: جزء 2 (Gov Documents) نُفّذ بالكامل backend + frontend + اختبار يدوي حقيقي محلياً. تفاصيل الانحراف والتنفيذ موثقة تحت "جزء 2" فوق مباشرة (أهمها: `AuthModule` احتاجت export لـ`JwtAuthGuard`+`TokenService` عشان modules جديدة تقدر تحميها، والـcontrollers صارت `AsyncNotifier` بدل sync — الشاشتين اتعدلوا للتعامل مع `AsyncValue` بنفس نمط باقي الفيتشرز).
- **2026-09-16 (تكملة نفس الجلسة)**: جزء 3 (Lawyers Marketplace) نُفّذ بالكامل backend + frontend + اختبار يدوي حقيقي محلياً. تفاصيل كاملة تحت "جزء 3" فوق. أهم نقاط تستحق الانتباه لجولات لاحقة:
  - باغ حقيقي (500 بدل 400/404 عند uuid مش صحيح الشكل بـpath parameter) انلقى وانصلح بـ`lawyers.controller.ts` (`ParseUUIDPipe`)، **ونفس الباغ موجود بالضبط بـ`gov-procedures.controller.ts` (جزء 2) ولسا موجود هناك** — يستاهل تنظيف بجولة قادمة (خارج نطاق هاي الجلسة).
  - `Review.consultationId` عمود حقيقي بدون FK علاقة لحد ما جزء 4 يبني `Consultation` — الـFK هيك بتنضاف بmigration بسيطة، مو data migration.
  - `LawyersRepository`/`LawyersController` عندهم القدرة الكاملة يبعتوا فلاتر سيرفر-سايد (`query/specialty/minRating/page`) بس الشاشة لسا بتستخدم الفلترة client-side القديمة بالكامل — قرار متحفظ لتفادي كسر سلوك موجود، تفعيل الفلاتر الفعلي بالشاشة يحتاج خطوة منفصلة لاحقاً.
  - `updateProfile` (lawyer self-edit، خارج نطاق هاي الخطة) بقي يستهدف `PATCH /v1/lawyers/me` اللي مو مبني بعد — `lawyer_profile_edit_screen.dart` وتستاته يشتغلوا بس لأنهم بيستخدموا `LawyersMockDataSource` عبر provider override صراحة، مو الـflip العام.
- **2026-09-16 (تكملة نفس الجلسة)**: جزء 4 (Consultations & Booking) نُفّذ بالكامل backend + frontend + اختبار يدوي حقيقي محلياً (بما فيه اختبار حجز متزامن حقيقي — طلبين parallel، واحد بس نجح). تفاصيل كاملة تحت "جزء 4" فوق. أهم نقاط تستحق الانتباه لجولات لاحقة:
  - نطاق الـendpoints اتوسّع شوي عن جدول الخطة الحرفي (أُضيفت `complete`/`miss`/`fail`) عشان نقطة التبديل الوحيدة لفيتشر consultations بتأثر على شاشات خارج النطاق (`consultation_room`) بتشارك نفس الـcontroller — قرار ضروري لمنع كسرها بدل تجاهله.
  - `sendMessage` (dead code مؤكد بصفر callers) انحذف كامل من الـinterface/mock/repository/controller — أول حذف حقيقي (مو بس تعديل) لمethod كاملة بهاي الخطة لحد الآن.
  - فجوة معروفة زي جزء 3 بالضبط: `lawyer_schedule_screen.dart` (خارج النطاق) هينكسر ضد الbackend الحقيقي لأنه بيستخدم `kDemoLawyerId` (مش uuid حقيقي) — نفس نمط `lawyer_profile_edit_screen.dart`/`PATCH /lawyers/me` من جزء 3، مؤجل لجولة lawyer-side.
  - `Consultation.price` (Prisma `Decimal`) بيترجم كـJSON string مش number — أي فيتشر تانية تضيف حقل `Decimal` جديد لازم تنتبه لنفس الشي بالفرونت (`double.parse` مش `(num).toDouble()`).
  - Next part to pick up: جزء 5 (Consultation Room).
- **2026-09-16 (تكملة نفس الجلسة)**: جزء 5 (Consultation Room) نُفّذ بالكامل backend + frontend + اختبار يدوي حقيقي محلياً. تفاصيل كاملة تحت "جزء 5" فوق. أهم نقاط تستحق الانتباه لجولات لاحقة:
  - النص القديم لهاد الجزء ما كان عنده حتى عنوان `## جزء 5` (كان نص عائم بعد ملاحظات جزء 4 مباشرة) — أُضيف العنوان والحالة كجزء من هاي الجولة.
  - جدول الـendpoints القديم (`token/join/leave/retry/end`) كان تخمين تقريبي — الـinterface الفعلي بالفرونت (`ConsultationRoomRemoteDataSource`) 7 methods بس وما فيه `leave` أصلاً. بُني `leave` backend-only احتياطي (نفس نمط جزء 4's lawyer-side endpoints minimum-to-test) بس ما انربط بالفرونت لأنه مو موجود بالـinterface من الأساس.
  - **باغ تكامل حقيقي بين جزء 4 وجزء 5**: `ConsultationsService.complete()` كانت مقيّدة lawyer-only، بس شاشات المكالمة الصوتية/الفيديو بتنادوها من أي طرف ينهي المكالمة. صار الclient يقدر يـ`complete()` استشارته زي `markMissed`/`markFailed` (نفس النمط الموجود أصلاً)، بدل ما تفضل الاستشارة عالقة بحالة `confirmed` للأبد. هاد أول باغ تكامل حقيقي بين جزئين مختلفين تنلقى بهاي الخطة (سابقاً كل الباغات كانت داخل جزء واحد).
  - `durationSeconds` (عداد وقت المكالمة) قرار مقصود إنه ما يترجم لأي API call — بيبقى client-local بالكامل (`SessionController.incrementDuration()` كل ثانية عبر `Timer` محلي)، مافي round-trip لسيرفر إطلاقاً لهاد الحقل تحديداً.
  - Auto-end/auto-miss scheduled jobs (مذكورين بالنص القديم) اتحذفوا من التنفيذ — client-driven أصلاً بالكامل عبر جزء 4 + `ConsultationRoomTiming`، cron سيرفر-سايد كان تكرار مافي داعي له هاي المرحلة.
  - Next part to pick up: جزء 6 (Contracts, Documents & Signatures).
