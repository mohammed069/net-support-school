import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'app_title': 'NetSupport School',
      'login_title': 'Welcome back',
      'login_subtitle':
          'Sign in to monitor students and manage exams in real time.',
      'sign_up_title': 'Create your account',
      'sign_up_subtitle':
          'Register with your basic details, then choose whether you are a tutor or a student.',
      'name': 'Name',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm password',
      'sign_up': 'Sign up',
      'create_account': 'Create account',
      'sign_in': 'Sign in',
      'sign_in_google': 'Continue with Google',
      'dont_have_account': 'Don\'t have an account? Create one',
      'already_have_account': 'Already have an account? Sign in',
      'success_account_created': 'Account created successfully.',
      'validation_name_required': 'Please enter your name.',
      'validation_email_required': 'Please enter your email.',
      'validation_password_required': 'Please enter your password.',
      'validation_confirm_password_required': 'Please confirm your password.',
      'validation_password_length': 'Password must be at least 6 characters.',
      'validation_password_mismatch': 'Passwords do not match.',
      'choose_role': 'Choose your role',
      'choose_role_subtitle':
          'Your role controls the screens, permissions, and real-time data you will see.',
      'student_role': 'Student',
      'tutor_role': 'Tutor',
      'student_home': 'Student Home',
      'tutor_dashboard': 'Tutor Dashboard',
      'logout': 'Logout',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'light_mode': 'Light',
      'dark_mode': 'Dark',
      'system_mode': 'System',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'students': 'Students',
      'exams': 'Exams',
      'reports': 'Reports',
      'status': 'Status',
      'locked': 'Locked',
      'unlocked': 'Unlocked',
      'live_tracking': 'Live tracking',
      'view_report': 'View report',
      'start_exam': 'Start exam',
      'stop_exam': 'Stop exam',
      'create_exam': 'Create exam',
      'exam_designer': 'Exam Designer',
      'exam_title': 'Exam title',
      'exam_description': 'Exam description',
      'duration_minutes': 'Duration (minutes)',
      'add_question': 'Add question',
      'first_question': 'First question',
      'question': 'Question',
      'option_1': 'Option 1',
      'option_2': 'Option 2',
      'option_3': 'Option 3',
      'option_4': 'Option 4',
      'correct_answer': 'Correct answer',
      'wrong_answer': 'Wrong answer',
      'save_add_another': 'Save and add another',
      'add_more_question': 'Add more',
      'validation_question_required':
          'Please enter the question, the correct answer, and all three wrong answers.',
      'validation_exam_required':
          'Please enter the exam title and description.',
      'save': 'Save',
      'cancel': 'Cancel',
      'submit_answers': 'Submit answers',
      'answer_all_questions': 'Please answer all questions before submitting.',
      'no_questions_available':
          'This exam does not have any questions yet. Ask your tutor to add questions first.',
      'remaining_time': 'Remaining time',
      'no_students': 'No students found yet.',
      'no_exams': 'No exams available yet.',
      'screen_locked_title': 'Screen locked',
      'screen_locked_message':
          'Your tutor has locked this screen. Please wait until it is unlocked.',
      'current_role': 'Current role',
      'welcome': 'Welcome',
      'idle': 'Idle',
      'started': 'Started',
      'finished': 'Finished',
      'score': 'Score',
      'answered': 'Answered',
      'assign_exam': 'Assign exam',
      'select_exam': 'Select exam',
      'select_students': 'Select students',
      'full_report': 'Full report',
      'active_exam': 'Active exam',
      'no_exam_assigned': 'No exam assigned',
      'success_exam_created': 'Exam created successfully.',
      'success_question_added': 'Question added successfully.',
      'success_role_saved': 'Role saved successfully.',
      'success_exam_started': 'Exam started for selected students.',
      'success_exam_stopped': 'Exam stopped.',
      'success_answers_submitted': 'Answers submitted successfully.',
      'success_locked': 'Student screen locked.',
      'success_unlocked': 'Student screen unlocked.',
      'error_generic': 'Something went wrong. Please try again.',
      'google_cancelled': 'Google sign in was cancelled.',
      'tracking_hint': 'Student activity updates automatically from Firestore.',
      'report_hint':
          'Scores and answer counts update after submissions are stored.',
      'create_first_exam':
          'Create your first exam to start assigning questions.',
      'empty_report': 'No submissions yet for this exam.',
      'open_designer': 'Open designer',
      'edit_questions': 'Edit questions',
      'add_mcq': 'Add MCQ',
      'question_bank': 'Questions',
      'active': 'Active',
      'inactive': 'Inactive',
      'auto_submitted': 'Time is up. The exam was submitted automatically.',
      'exam_ready': 'Exam is ready.',
      'login_required': 'Please sign in first.',
      'pick_exam_for_report': 'Pick an exam to load reports.',
    },
    'ar': {
      'app_title': 'نت سبورت سكول',
      'login_title': 'مرحباً بعودتك',
      'login_subtitle':
          'سجل الدخول لمتابعة الطلاب وإدارة الاختبارات بشكل لحظي.',
      'sign_up_title': 'أنشئ حسابك',
      'sign_up_subtitle':
          'سجل بياناتك الأساسية أولاً ثم اختر إذا كنت معلماً أم طالباً.',
      'name': 'الاسم',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'sign_up': 'إنشاء حساب',
      'create_account': 'إنشاء الحساب',
      'sign_in': 'تسجيل الدخول',
      'sign_in_google': 'المتابعة باستخدام جوجل',
      'dont_have_account': 'ليس لديك حساب؟ أنشئ واحداً',
      'already_have_account': 'لديك حساب بالفعل؟ سجل الدخول',
      'success_account_created': 'تم إنشاء الحساب بنجاح.',
      'validation_name_required': 'يرجى إدخال الاسم.',
      'validation_email_required': 'يرجى إدخال البريد الإلكتروني.',
      'validation_password_required': 'يرجى إدخال كلمة المرور.',
      'validation_confirm_password_required': 'يرجى تأكيد كلمة المرور.',
      'validation_password_length': 'يجب ألا تقل كلمة المرور عن 6 أحرف.',
      'validation_password_mismatch': 'كلمتا المرور غير متطابقتين.',
      'choose_role': 'اختر الدور',
      'choose_role_subtitle':
          'الدور يحدد الشاشات والصلاحيات والبيانات اللحظية التي ستظهر لك.',
      'student_role': 'طالب',
      'tutor_role': 'معلم',
      'student_home': 'الرئيسية للطالب',
      'tutor_dashboard': 'لوحة المعلم',
      'logout': 'تسجيل الخروج',
      'settings': 'الإعدادات',
      'appearance': 'المظهر',
      'light_mode': 'فاتح',
      'dark_mode': 'داكن',
      'system_mode': 'النظام',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'students': 'الطلاب',
      'exams': 'الاختبارات',
      'reports': 'التقارير',
      'status': 'الحالة',
      'locked': 'مغلق',
      'unlocked': 'مفتوح',
      'live_tracking': 'متابعة مباشرة',
      'view_report': 'عرض التقرير',
      'start_exam': 'بدء الاختبار',
      'stop_exam': 'إيقاف الاختبار',
      'create_exam': 'إنشاء اختبار',
      'exam_designer': 'مصمم الاختبارات',
      'exam_title': 'عنوان الاختبار',
      'exam_description': 'وصف الاختبار',
      'duration_minutes': 'المدة بالدقائق',
      'add_question': 'إضافة سؤال',
      'first_question': 'السؤال الأول',
      'question': 'السؤال',
      'option_1': 'الخيار 1',
      'option_2': 'الخيار 2',
      'option_3': 'الخيار 3',
      'option_4': 'الخيار 4',
      'correct_answer': 'الإجابة الصحيحة',
      'wrong_answer': 'إجابة خاطئة',
      'save_add_another': 'حفظ وإضافة أخرى',
      'add_more_question': 'إضافة المزيد',
      'validation_question_required':
          'يرجى إدخال السؤال والإجابة الصحيحة والإجابات الخاطئة الثلاث.',
      'validation_exam_required': 'يرجى إدخال عنوان الاختبار والوصف.',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'submit_answers': 'تسليم الإجابات',
      'answer_all_questions': 'يرجى الإجابة على جميع الأسئلة قبل التسليم.',
      'no_questions_available':
          'هذا الاختبار لا يحتوي على أسئلة حتى الآن. اطلب من المعلم إضافة الأسئلة أولاً.',
      'remaining_time': 'الوقت المتبقي',
      'no_students': 'لا يوجد طلاب حتى الآن.',
      'no_exams': 'لا توجد اختبارات حتى الآن.',
      'screen_locked_title': 'الشاشة مقفلة',
      'screen_locked_message':
          'قام المعلم بقفل هذه الشاشة. يرجى الانتظار حتى يتم فتحها.',
      'current_role': 'الدور الحالي',
      'welcome': 'مرحباً',
      'idle': 'جاهز',
      'started': 'بدأ',
      'finished': 'انتهى',
      'score': 'الدرجة',
      'answered': 'تمت الإجابة',
      'assign_exam': 'إسناد الاختبار',
      'select_exam': 'اختر اختباراً',
      'select_students': 'اختر الطلاب',
      'full_report': 'التقرير الكامل',
      'active_exam': 'الاختبار النشط',
      'no_exam_assigned': 'لا يوجد اختبار مسند',
      'success_exam_created': 'تم إنشاء الاختبار بنجاح.',
      'success_question_added': 'تمت إضافة السؤال بنجاح.',
      'success_role_saved': 'تم حفظ الدور بنجاح.',
      'success_exam_started': 'تم بدء الاختبار للطلاب المحددين.',
      'success_exam_stopped': 'تم إيقاف الاختبار.',
      'success_answers_submitted': 'تم تسليم الإجابات بنجاح.',
      'success_locked': 'تم قفل شاشة الطالب.',
      'success_unlocked': 'تم فتح شاشة الطالب.',
      'error_generic': 'حدث خطأ ما. حاول مرة أخرى.',
      'google_cancelled': 'تم إلغاء تسجيل الدخول بجوجل.',
      'tracking_hint': 'يتم تحديث نشاط الطالب تلقائياً من فايرستور.',
      'report_hint': 'يتم تحديث الدرجات وعدد الإجابات بعد حفظ التسليمات.',
      'create_first_exam': 'أنشئ أول اختبار لبدء إسناد الأسئلة.',
      'empty_report': 'لا توجد تسليمات لهذا الاختبار حتى الآن.',
      'open_designer': 'فتح المصمم',
      'edit_questions': 'تعديل الأسئلة',
      'add_mcq': 'إضافة سؤال اختيار من متعدد',
      'question_bank': 'الأسئلة',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'auto_submitted': 'انتهى الوقت وتم تسليم الاختبار تلقائياً.',
      'exam_ready': 'الاختبار جاهز.',
      'login_required': 'يرجى تسجيل الدخول أولاً.',
      'pick_exam_for_report': 'اختر اختباراً لتحميل التقارير.',
    },
  };

  String text(String key) {
    final languageCode = locale.languageCode;
    return _values[languageCode]?[key] ?? _values['en']![key] ?? key;
  }

  String formatDateTime(DateTime? value) {
    if (value == null) {
      return '--';
    }

    final normalizedLocale = Intl.canonicalizedLocale(locale.toLanguageTag());
    return DateFormat('dd MMM yyyy, hh:mm a', normalizedLocale).format(value);
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
