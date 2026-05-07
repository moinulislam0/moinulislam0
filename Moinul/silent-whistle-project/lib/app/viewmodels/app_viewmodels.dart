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
import 'package:jwells/features/home/presentation/provider_model/load_reply_provider.dart';
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
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../core/di/di_config.dart';
import '../../features/auth/model_view/login_screen_provider.dart';
import '../../features/auth/model_view/sign_screen_provider.dart';
import '../../features/home/presentation/viewmodel/home_viewmodel.dart';
import '../../features/parent/model_view/parent_screen_provider.dart';
import '../../features/payment/presentation/viewnodel/subscription_provider.dart';
import '../../features/profile/presentation/viewmodel/shout_delete_provider.dart';
import '../../features/profile/presentation/viewmodel/update_profile_picture_provider.dart';

class AppViewModels {
  static final List<SingleChildWidget> viewmodels = [
    ChangeNotifierProvider<HomeViewModel>(
      create: (_) => getIt<HomeViewModel>(),
    ),
    ChangeNotifierProvider<ParentScreenProvider>(
      create: (_) => getIt<ParentScreenProvider>(),
    ),
    ChangeNotifierProvider<LoginScreenProvider>(
      create: (_) => getIt<LoginScreenProvider>(),
    ),
    ChangeNotifierProvider<SignScreenProvider>(
      create: (_) => getIt<SignScreenProvider>(),
    ),
    ChangeNotifierProvider<ForgotScreenProvider>(
      create: (_) => getIt<ForgotScreenProvider>(),
    ),
    ChangeNotifierProvider<CustomAppBarProvider>(
      create: (_) => getIt<CustomAppBarProvider>(),
    ),
    ChangeNotifierProvider<FotgetVerifyProvider>(
      create: (_) => getIt<FotgetVerifyProvider>(),
    ),
    ChangeNotifierProvider<NewPasswordVerify>(
      create: (_) => getIt<NewPasswordVerify>(),
    ),
    ChangeNotifierProvider<SignUpScreenProvider>(
      create: (_) => getIt<SignUpScreenProvider>(),
    ),
    ChangeNotifierProvider<ResendCodeProvider>(
      create: (_) => getIt<ResendCodeProvider>(),
    ),
    ChangeNotifierProvider<ShoutProvider>(
      create: (_) => getIt<ShoutProvider>(),
    ),
    ChangeNotifierProvider<CreateShoutProvider>(
      create: (_) => getIt<CreateShoutProvider>(),
    ),
    ChangeNotifierProvider<isLikedProvider>(
      create: (_) => getIt<isLikedProvider>(),
    ),
    ChangeNotifierProvider<unLikedProvider>(
      create: (_) => getIt<unLikedProvider>(),
    ),

    ChangeNotifierProvider<ProfileProvider>(
      create: (_) => getIt<ProfileProvider>(),
    ),
    ChangeNotifierProvider<ReplyCommentProvider>(
      create: (_) => getIt<ReplyCommentProvider>(),
    ),

    ChangeNotifierProvider<ProfileProvider>(
      create: (_) => getIt<ProfileProvider>(),
    ),
    ChangeNotifierProvider<AlertProvider>(
      create: (_) => getIt<AlertProvider>(),
    ),


    ChangeNotifierProvider<ShoutPostDeleteProvider>(
      create: (_) => getIt<ShoutPostDeleteProvider>(),
    ),
    ChangeNotifierProvider<AlertDeleteProvider>(
      create: (_) => getIt<AlertDeleteProvider>(),
    ),

    ChangeNotifierProvider<UpdateUserProvider>(
      create: (_) => getIt<UpdateUserProvider>(),
    ),
    ChangeNotifierProvider<LoadRepliedProvider>(
      create: (_) => getIt<LoadRepliedProvider>(),
    ),
    ChangeNotifierProvider<ShareProvider>(
      create: (_) => getIt<ShareProvider>(),
    ),

   
    ChangeNotifierProvider<LikeCommentProvider>(
      create: (_) => getIt<LikeCommentProvider>(),
    ),
    ChangeNotifierProvider<unLikedCommentProvider >(
      create: (_) => getIt<unLikedCommentProvider >(),
    ),
    ChangeNotifierProvider<MapProvider >(
      create: (_) => getIt<MapProvider >(),
    ),
    ChangeNotifierProvider<MapSaveProvider >(
      create: (_) => getIt<MapSaveProvider >(),
    ),
    ChangeNotifierProvider<MapGetProvider>(
      create: (_) => getIt<MapGetProvider >(),
    ),
    ChangeNotifierProvider<MapDeleteProvider>(
      create: (_) => getIt<MapDeleteProvider >(),
    ),
    ChangeNotifierProvider<EditProfileProvider >(
      create: (_) => getIt<EditProfileProvider  >(),
    ),
    ChangeNotifierProvider<DeleteAccountProvider >(
      create: (_) => getIt<DeleteAccountProvider  >(),
    ),
    ChangeNotifierProvider<DisableAccountProvider>(
      create: (_) => getIt<DisableAccountProvider >(),
    ),
    ChangeNotifierProvider<EnableAccoutProvider>(
      create: (_) => getIt<EnableAccoutProvider>(),
    ),
    ChangeNotifierProvider<ChangePasswordProvider>(
      create: (_) => getIt<ChangePasswordProvider>(),
    ),
    ChangeNotifierProvider<SupportProvider>(
      create: (_) => getIt<SupportProvider>(),
    ),
    ChangeNotifierProvider<EditShoutProvider>(
      create: (_) => getIt<EditShoutProvider>(),
    ),
    ChangeNotifierProvider<ReportUserProvider>(
      create: (_) => getIt<ReportUserProvider>(),
    ),
    ChangeNotifierProvider<BlockUserProvider>(
      create: (_) => getIt<BlockUserProvider>(),
    ),
    ChangeNotifierProvider<BlockedUsersProvider>(
      create: (_) => getIt<BlockedUsersProvider>(),
    ),
  

  ];
}
