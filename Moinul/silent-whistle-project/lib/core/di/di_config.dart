import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:jwells/features/alerts/screen/viewmodel/alert_delete_provider.dart';
import 'package:jwells/features/alerts/screen/viewmodel/alert_provider.dart';
import 'package:jwells/features/auth/model_view/edit_profile_provider.dart';
import 'package:jwells/features/auth/model_view/forgot_screen_provider.dart';
import 'package:jwells/features/auth/model_view/fotget_verify_provider.dart';
import 'package:jwells/features/auth/model_view/new_password_verify.dart';
import 'package:jwells/features/auth/model_view/resend_code_provider.dart';
import 'package:jwells/features/auth/model_view/shout_provider.dart';
import 'package:jwells/features/auth/model_view/sign_up_screen_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/_isLiked_provider_model.dart';
import 'package:jwells/features/home/presentation/provider_model/_unliked_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/like_comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/reply_comment_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/share_provider.dart';
import 'package:jwells/features/home/presentation/provider_model/unlike_comment_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_delete_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_get_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_provider.dart';
import 'package:jwells/features/map/screen/view_model/map_save_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/change_password_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/blocked_users_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/block_user_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/delete_account_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/disable_account_provider.dart';

import 'package:jwells/features/profile/presentation/viewmodel/enable_accout_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/profile_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/report_user_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/shout_edit_provider.dart';
import 'package:jwells/features/profile/presentation/viewmodel/support_provider.dart';
import 'package:jwells/features/shout/presentation/viewModel/provider/create_shout_provider.dart';
import 'package:jwells/features/widget_custom/custom_app_bar_provider.dart';

import '../../features/auth/model_view/login_screen_provider.dart';
import '../../features/auth/model_view/sign_screen_provider.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/viewmodel/home_viewmodel.dart';
import '../../features/parent/model_view/parent_screen_provider.dart';
import '../../features/payment/presentation/viewnodel/subscription_provider.dart';
import '../../features/profile/presentation/viewmodel/shout_delete_provider.dart';
import '../../features/profile/presentation/viewmodel/update_profile_picture_provider.dart';
import '../services/api_services/api_services.dart';

final GetIt getIt = GetIt.instance;

Future<void> diConfig() async {
  // ore Services
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repository Layer
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<ApiService>()),
  );

  // ViewModels
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel());

  // ViewModels
  getIt.registerFactory<ParentScreenProvider>(() => ParentScreenProvider());

  getIt.registerFactory<LoginScreenProvider>(() => LoginScreenProvider());
  getIt.registerFactory<SignScreenProvider>(() => SignScreenProvider());
  getIt.registerFactory<ForgotScreenProvider>(() => ForgotScreenProvider());
  getIt.registerFactory<FotgetVerifyProvider>(() => FotgetVerifyProvider());
  getIt.registerFactory<NewPasswordVerify>(() => NewPasswordVerify());
  getIt.registerFactory<SignUpScreenProvider>(() => SignUpScreenProvider());
  getIt.registerFactory<ResendCodeProvider>(() => ResendCodeProvider());
  getIt.registerFactory<ShoutProvider>(() => ShoutProvider());
  getIt.registerFactory<CreateShoutProvider>(() => CreateShoutProvider());
  getIt.registerFactory<isLikedProvider>(() => isLikedProvider());
  getIt.registerFactory<unLikedProvider>(() => unLikedProvider());
  getIt.registerFactory<ReplyCommentProvider>(() => ReplyCommentProvider());
  getIt.registerFactory<AlertProvider>(() => AlertProvider());
  getIt.registerFactory<AlertDeleteProvider>(() => AlertDeleteProvider());
  getIt.registerFactory<ShareProvider>(() => ShareProvider());
  getIt.registerFactory<LikeCommentProvider>(() => LikeCommentProvider());
  getIt.registerFactory<unLikedCommentProvider >(() => unLikedCommentProvider ());
  getIt.registerFactory<MapProvider >(() => MapProvider ());
  getIt.registerFactory<MapSaveProvider >(() => MapSaveProvider());
  getIt.registerFactory<MapGetProvider>(() => MapGetProvider());
  getIt.registerFactory<MapDeleteProvider>(() => MapDeleteProvider());
  getIt.registerFactory<EditProfileProvider >(() => EditProfileProvider ());
  getIt.registerFactory<DeleteAccountProvider  >(() => DeleteAccountProvider ());
  getIt.registerFactory<DisableAccountProvider >(() => DisableAccountProvider ());
  getIt.registerFactory<EnableAccoutProvider>(() => EnableAccoutProvider());
  getIt.registerFactory<ChangePasswordProvider>(() => ChangePasswordProvider());
  getIt.registerFactory<SupportProvider>(() => SupportProvider());
  getIt.registerFactory<EditShoutProvider >(() => EditShoutProvider ());
  getIt.registerFactory<ReportUserProvider>(
    () => ReportUserProvider(getIt<ApiService>()),
  );
  getIt.registerFactory<BlockUserProvider>(
    () => BlockUserProvider(getIt<ApiService>()),
  );
  getIt.registerFactory<BlockedUsersProvider>(
    () => BlockedUsersProvider(getIt<ApiService>()),
  );
 

  getIt.registerLazySingleton<CustomAppBarProvider>(
    () => CustomAppBarProvider(getIt<ApiService>()),
  );

  getIt.registerFactory<ProfileProvider>(() => ProfileProvider(getIt<ApiService>()),);
  getIt.registerFactory<ShoutPostDeleteProvider>(() => ShoutPostDeleteProvider(getIt<ApiService>()),);
  getIt.registerFactory<UpdateUserProvider>(() => UpdateUserProvider(getIt<ApiService>()),);
  
 

}
