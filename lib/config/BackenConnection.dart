class BackenConnection {
  String url = 'https://localhost:8000';
  String registerApi = '/api/register';

  String get loginApi => '/api/login';

  String get createCompanyApi => '/api/protected/create-company';

  String get getMyCompaniesApi => '/api/protected/get-my-companies';

  String get getCompanyApi => '/api/get-company/';

  String get getMyEducationInstitutionsApi => "/api/protected/get-my-education-institutions";

  String get addEducationInstitutionApi => "/api/protected/create-education-institution";

  String get searchUsersApi => "/api/protected/search-user";

  String get addEmployeeApi => "/api/protected/add-an-employee";

  String get saveWalletAddressApi => "/api/protected/set-ethereum-wallet";

  String get getCurrentUserApi => "/api/protected/get-current-user";

  String get saveCompanyWalletAddressApi => "/api/protected/company/add-ethereum-wallet";

  String get getUserApi => "/api/protected/get-user/";

  String get getEducationInstitutionApi => "/api/protected/get-education-institution/";

  String get setEthereumAddressForTeachingInstitutionApi => '/api/protected/education-institution/set-ethereum-address';

  String get addManuallyAddedWorkExperienceApi => "/api/protected/add-manually-a-work-experience";

  String get getMyManuallyAddedWorkExperiencesApi => "/api/protected/get-my-manually-added-work-experience";

  String get addMyCertificateManuallyApi => "/api/protected/add-manually-a-certification";

  String get getMyManuallyAddedCertificatesApi => "/api/protected/get-my-manually-added-certificates";

  String get addSkillApi => '/api/protected/add-skill';

  String get getMySkillsApi => '/api/protected/get-my-skills';

  String get getSkillApi => "/api/protected/get-skill/";

  String get getAQuestionsForSkillApi => "/skill/get-a-question/";

  String get sendAnswerToAI => "/skill/send-answer";

  String get getFeedbacksOnSkillsApi => "/skill/get-ai-feed-back/";

  String get getSkillsFromUserApi => "/api/protected/get-skills-from-user/";

  String get getFeedbacksOnProfileApi => "/api/protected/get-ai-feedback-on-user-for-a-job-description";


  String get getAllUsersForAdmin => "/api/admin/get-all-users";

  String get getAllCompaniesForAdmin => "/api/admin/get-all-companies";

  String get getAllEducationInstitutionsForAdmin => "/api/admin/get-all-education-institutions";
  
  String get getAllStatisticsForAdmin => "/api/admin/get-all-statistics";
  
  String get addManuallyPromotion => "/api/protected/add-manually-promotion/";

  String get companyProfilePicFolder => '/assets/company/profile-pictures/';

  String get userProfilePicFolder => '/assets/user/profile-pictures/';

  String get imageAssetFolder => '/assets/images/';

  String get educationInstitutionProfilePicFolder => '/assets/education-institution/profile-pictures/';

  String get updateCompany => '/api/protected/update-company/';

  String get updateUser => '/api/protected/update-user/';

  String get getCompanyByEthereumAddress => '/api/protected/get-company-by-ethereum-address/';

  String get getEducationInstitutionByEthereumAddress => '/api/protected/get-education-institution-by-ethereum-address/';

  String get getMyExportedCv => '/api/protected/export-cv';

  String get getMyCvPlace => "/assets/cv/";

  String get updateEducationInstitution=> "/api/protected/update-education-institution/";

  String get getUsersManuallyAddedExperiences => "/api/protected/get-users-manually-added-work-experience/";

  String get getUsersManuallyAddedCertificates => "/api/protected/get-users-manually-added-certificates/";
  
  String get verifyEmail => "/api/verify-email/";

  String get resendEmailVerification => "/api/resend-email-verification";

  String get requestPasswordReset => "/api/request-password-reset";

  String get resetPassword => "/api/reset-password";

  String get deleteManualExperience => "/api/protected/delete-manually-added-work-experience/";

  String get deleteManualyAddedCertificate => "/api/protected/delete-manually-added-certification/";

  String get createJobOfferApi => "/api/protected/create-job-offer";

  String get getJobOffersByCompanyApi => "/api/protected/company/all-job-offers/";

  String get getJobOfferByIdApi => "/api/protected/company/get-job-offer/";

  String get updateJobOfferApi => "/api/protected/company/update-job-offer";

  String get deleteJobOfferApi => "/api/protected/company/delete-job-offer/";

  String get getAllPublicJobOffersApi => "/api/get-public-job-offers";

  String get getPublicJobOfferByIdApi => "/api/get-public-job-offer/";

  String get applyToJobOfferApi => "/api/protected/apply-job-offer/";

  String get getApplicationsToJobOfferApi => "/api/protected/company/get-job-offer-applicants/";

  String get generateAIFeedbackApi => "/api/protected/company/job-offer-applicants/generate-ai-feedback/";

  String get getAIFeedbackApi => "/api/protected/company/job-offer-applicants/get-ai-feedback/";

  String get uploadCvApi => "/api/protected/extract-cv-data";

  String get updateExperienceApi => "/api/protected/edit-manually-added-work-experience";

  String get updateCertificateApi => "/api/protected/update-manually-added-certification";

  String get deleteSkillApi => "/api/protected/delete-skill/";

  String get getMySkillTestQuestionCountApi => "/api/protected/get-my-skills-question-count";

  String get setFirstConfigurationDoneApi => "/api/protected/set-first-configuration-done";

  String get getCompanyAdministratorsApi => "/api/protected/company/get-admins/";

  String get addCompanyAdministratorApi => "/api/protected/company/add-admin";

  String get removeCompanyAdministratorApi => '/api/protected/company/remove-admin';

  String get hasCompletedCvApi => "/api/protected/user/has-completed-cv";

  String get getCareerAdviceApi => "/api/protected/user/get-career-advice";
  
  String get verifyCompanyApi => "/api/admin/verify-company";
  
  String get unverifyCompanyApi => "/api/admin/unverify-company";
  
  String get verifyEducationInstitutionApi => "/api/admin/verify-education-institution";
  
  String get unverifyEducationInstitutionApi => "/api/admin/unverify-education-institution";

  String get getAllPublicJobOffersByCompanyApi => "/api/get-public-job-offers-by-company/";

  // Weekly Recommendations API endpoints
  String get getCurrentWeekRecommendationsApi => "/api/protected/get-this-week-recommandation";

  String get getWeeklyProgressApi => "/api/protected/weekly-recommendations/progress";

  String get markCourseCompletedApi => "/api/protected/weekly-recommendations/course/complete";

  String get registerForEventApi => "/api/protected/weekly-recommendations/event/register";

  String get unregisterFromEventApi => "/api/protected/weekly-recommendations/event/unregister/";

  String get getRecommendationHistoryApi => "/api/protected/weekly-recommendations/history";

  String get getRecommendationsForWeekApi => "/api/protected/weekly-recommendations/week/";

  String get getAiGeneratedCourseApi => "/api/protected/get-ai-genereted-weekly-course/";

}