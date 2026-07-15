class URLS {
  static const String BASE_URL = 'https://popadmin.cyberimpulses.tech/API/';

  /// Builds a full API URL from an endpoint filename.
  static String api(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }
    return BASE_URL + endpoint;
  }

/*--------------------------------------------SIGNUP PROCESS------------------------------------*/

  static const String DRIVER_REGISTER = 'driver_signup.php';
  static const String VEHICLE_FETCH = 'fetch_vehicle_list.php';
  static const String DRIVER_ADD_BANK_DETAIL = 'driver_add_bank_details.php';
  static const String fetch_driver_bank_details =
      'fetch_driver_bank_details.php';
  static const String DRIVER_LOGIN = 'driver_login.php';
  static const String DRIVER_SIGNUP_CHECK = 'driver_signup_recheck.php';
  static const String DRIVER_SIGNUP = 'driver_signup.php';
  static const String DRIVER_FORGET_PASSWORD = 'send_driver_otp.php';
  static const String send_otp = 'send_otp.php';
  static const String verify_driver_otp = 'verify_driver_otp.php';
  static const String varify_booking_start_otp = 'varify_booking_start_otp.php';
  static const String DRIVER_SET_PASSWORD = 'change_driver_password.php';
  static const String DRIVER_LOGOUT = 'driver_logout.php';
  static const String DRIVER_LOGIN_CHECK = 'driver_login_recheck.php';
  static const String check_driver_admin_status =
      'check_driver_admin_status.php';
  static const String DRIVER_DELETE_ACCOUNT = 'delete_driver.php';
  static const String fetch_membership_list = 'fetch_membership_list.php';
  static const String driver_add_membership = 'driver_add_membership.php';
  static const String check_payment_status = 'check_payment_status.php';
  static const String driver_add_membership_complete = 'membership_payment.php';

/*--------------------------------------------DEVICE_ID_UPDATE------------------------------------*/

  static const String DEVICE_ID_UPDATE = 'update_driverdevice_id.php';
  static const String DRIVER_LATLONG_UPDATE = 'update_driver_latlong.php';
  static const String FETCH_DRIVER_AVAILABILITY_STATUS =
      'fetch_driver_availability_status.php';

/*--------------------------------------------PROFILE PROCESS------------------------------------*/

  static const String DRIVER_FETCH_DETAIL = 'fetch_driver_detail.php';
  static const String DRIVER_UPDATE_DETAIL = 'update_driver_profile.php';
  static const String DRIVER_UPDATE_PASSWORD = 'update_driver_password.php';
  static const String DRIVER_UPDATE_PROFILE_IMAGE =
      'update_driver_profile_image.php';
  static const String UPDATE_DRIVER_SELFIE = 'update_driver_salfie.php';

/*--------------------------------------------NOTIFICATION PROCESS------------------------------------*/

  static const String DRIVER_NOTIFICATION =
      'fetch_driver_notification_list.php';
  static const String DRIVER_NOTIFICATION_DELETE =
      'delete_driver_notification.php';

/*--------------------------------------------WALLET PROCESS------------------------------------*/

  static const String DRIVER_WALLET_FETCH = 'fetch_driver_wallet.php';
  static const String DRIVER_LIST_FETCH = 'fetch_user_driver_list.php';
  static const String SEND_WALLET_AMOUNT_TO_DRIVER =
      'send_driver_wallet_amount.php';
  static const String DRIVER_WALLET_TRANSACTION_HISTORY =
      'fetch_driver_wallet_transaction_history.php';
  static const String DRIVER_WALLET_HISTORY_DOWNLOAD = 'salary_exel_file.php';
  static const String add_driver_amount = 'add_driver_amount.php';
  static const String wallet_payment_driver_main = 'wallet_payment_driver.php';
  static const String add_driver_withdraw_request =
      'add_driver_withdraw_request.php';

/*--------------------------------------------CARD PROCESS------------------------------------*/

  static const String ADD_DRIVER_CARD = 'add_driver_card';
  static const String FETCH_DRIVER_CARD = 'fetch_driver_card';
  static const String DELETE_DRIVER_CARD = 'delete_driver_card';

/*--------------------------------------------RIDE PROCESS------------------------------------*/

  static const String DRIVER_TOTAL_BOOKING =
      'driver_completed_booking_data.php';
  static const String DRIVER_RIDE_HISTORY =
      'fetch_driver_booking_history_list.php';

/*--------------------------------------------BOOKING PROCESS------------------------------------*/

  static const String FETCH_RIDE_NOW_BOOKING = 'fetch_driver_ride_now_list.php';
  static const String FETCH_RIDE_LATER_BOOKING =
      'fetch_driver_ride_later_list.php';
  static const String DRIVER_ACCEPT_BOOKING =
      'driver_intrested_booking_status.php';
  static const String DRIVER_CANCEL_BOOKING =
      'driver_cancel_booking_status.php';
  static const String USER_ACCEPT_BOOKING =
      'driver_fetch_confirm_booking_user_details.php';
  static const String DRIVER_UPDATE_LAT_LONG = 'update_driverlatlong.php';
  static const String STATUS_CHANGE = 'driver_update_booking_status.php';
  static const String RATINGTOUSER = 'insert_user_rating.php';
  static const String DRIVER_BOOKING_DETAILS =
      'driver_fetch_booking_details.php';
  static const String RIDE_LATER_SCREEN_DRIVER_BOOKING =
      'fetch_driver_Ride_later_booking_list.php';
  static const String RIDE_LATER_SCREEN_DRIVER_BOOKING_START =
      'driver_start_booking.php';
  static const String CANCEL_BOOKING = 'driver_cancel_booking.php';
  static const String DRIVER_RATING = 'fetch_driver_rating_list.php';

/*--------------------------------------------BOOKING REPORT------------------------------------*/

  static const String REPORT = 'add_driver_complain.php';
  static const String PAIN_BUTTON = 'add_driver_panic_notification.php';
  static const String DRIVER_SUPPORT = 'driver_write_support.php';

/*--------------------------------------------SUPPORT / POLICY PAGES------------------------------------*/

  static const String DRIVER_PRIVACY_POLICY = 'driver_privacy_policy.php';
  static const String DRIVER_TERM_CONDITION = 'driver_term_condition.php';
  static const String DRIVER_FAQ = 'driver_faq.php';

/*--------------------------------------------MESSAGE------------------------------------*/

  static const String SEND_MESSAGE = 'driver_send_msg.php';
  static const String FETCH_MESSAGE = 'fetch_driver_send_msg.php';

  static const String FETCH_QUERY = 'fetch_driver_write_support_list.php';
  static const String SINGLE_QUERY = 'driver_fetch_single_thread.php';
  static const String CLOSE_TICKET = 'driver_close_ticket.php';
  static const String CLOSE_TICKET1 = 'driver_close_complain_ticket.php';
  static const String THREAD_REPLY = 'driver_reply_thread.php';
  static const String THREAD_REPLY_Come = 'driver_reply_compain_thread.php';
  static const String FETCH_Com = 'fetch_driver_complain_list.php';
  static const String FETCH_Single_Com =
      'driver_fetch_single_complain_thread.php';
}
