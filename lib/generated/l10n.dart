// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Select your preferred languages`
  String get select_your_preferred_languages {
    return Intl.message(
      'Select your preferred languages',
      name: 'select_your_preferred_languages',
      desc: '',
      args: [],
    );
  }

  /// `Order Id`
  String get order_id {
    return Intl.message(
      'Order Id',
      name: 'order_id',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Checkout`
  String get checkout {
    return Intl.message(
      'Checkout',
      name: 'checkout',
      desc: '',
      args: [],
    );
  }

  /// `Payment Mode`
  String get payment_mode {
    return Intl.message(
      'Payment Mode',
      name: 'payment_mode',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message(
      'Subtotal',
      name: 'subtotal',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `Favorite Foods`
  String get favorite_foods {
    return Intl.message(
      'Favorite Foods',
      name: 'favorite_foods',
      desc: '',
      args: [],
    );
  }

  /// `Extras`
  String get extras {
    return Intl.message(
      'Extras',
      name: 'extras',
      desc: '',
      args: [],
    );
  }

  /// `Faq`
  String get faq {
    return Intl.message(
      'Faq',
      name: 'faq',
      desc: '',
      args: [],
    );
  }

  /// `Help & Supports`
  String get help_supports {
    return Intl.message(
      'Help & Supports',
      name: 'help_supports',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get app_language {
    return Intl.message(
      'App Language',
      name: 'app_language',
      desc: '',
      args: [],
    );
  }

  /// `I forgot password ?`
  String get i_forgot_password {
    return Intl.message(
      'I forgot password ?',
      name: 'i_forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `I don't have an account?`
  String get i_dont_have_an_account {
    return Intl.message(
      'I don\'t have an account?',
      name: 'i_dont_have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `TAX`
  String get tax {
    return Intl.message(
      'TAX',
      name: 'tax',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Cash on delivery`
  String get cash_on_delivery {
    return Intl.message(
      'Cash on delivery',
      name: 'cash_on_delivery',
      desc: '',
      args: [],
    );
  }

  /// `Recent Orders`
  String get recent_orders {
    return Intl.message(
      'Recent Orders',
      name: 'recent_orders',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Profile Settings`
  String get profile_settings {
    return Intl.message(
      'Profile Settings',
      name: 'profile_settings',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get full_name {
    return Intl.message(
      'Full name',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `App Settings`
  String get app_settings {
    return Intl.message(
      'App Settings',
      name: 'app_settings',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get help_support {
    return Intl.message(
      'Help & Support',
      name: 'help_support',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message(
      'Register',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `Let's Start with register!`
  String get lets_start_with_register {
    return Intl.message(
      'Let\'s Start with register!',
      name: 'lets_start_with_register',
      desc: '',
      args: [],
    );
  }

  /// `Another step!`
  String get another_step {
    return Intl.message(
      'Another step!',
      name: 'another_step',
      desc: '',
      args: [],
    );
  }

  /// `Select a file`
  String get select_a_file {
    return Intl.message(
      'Select a file',
      name: 'select_a_file',
      desc: '',
      args: [],
    );
  }

  /// `Should be more than 3 letters`
  String get should_be_more_than_3_letters {
    return Intl.message(
      'Should be more than 3 letters',
      name: 'should_be_more_than_3_letters',
      desc: '',
      args: [],
    );
  }

  /// `John Doe`
  String get john_doe {
    return Intl.message(
      'John Doe',
      name: 'john_doe',
      desc: '',
      args: [],
    );
  }

  /// `Should be a valid email`
  String get should_be_a_valid_email {
    return Intl.message(
      'Should be a valid email',
      name: 'should_be_a_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Should be more than 6 letters`
  String get should_be_more_than_6_letters {
    return Intl.message(
      'Should be more than 6 letters',
      name: 'should_be_more_than_6_letters',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `I have account? Back to login`
  String get i_have_account_back_to_login {
    return Intl.message(
      'I have account? Back to login',
      name: 'i_have_account_back_to_login',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Order`
  String get tracking_order {
    return Intl.message(
      'Tracking Order',
      name: 'tracking_order',
      desc: '',
      args: [],
    );
  }

  /// `Discover & Explorer`
  String get discover__explorer {
    return Intl.message(
      'Discover & Explorer',
      name: 'discover__explorer',
      desc: '',
      args: [],
    );
  }

  /// `You can discover restaurants & fastfood arround you and choose you best meal after few minutes we prepare and delivere it for you`
  String get you_can_discover_restaurants {
    return Intl.message(
      'You can discover restaurants & fastfood arround you and choose you best meal after few minutes we prepare and delivere it for you',
      name: 'you_can_discover_restaurants',
      desc: '',
      args: [],
    );
  }

  /// `Reset Cart?`
  String get reset_cart {
    return Intl.message(
      'Reset Cart?',
      name: 'reset_cart',
      desc: '',
      args: [],
    );
  }

  /// `Cart`
  String get cart {
    return Intl.message(
      'Cart',
      name: 'cart',
      desc: '',
      args: [],
    );
  }

  /// `Shopping Cart`
  String get shopping_cart {
    return Intl.message(
      'Shopping Cart',
      name: 'shopping_cart',
      desc: '',
      args: [],
    );
  }

  /// `Verify your quantity and click checkout`
  String get verify_your_quantity_and_click_checkout {
    return Intl.message(
      'Verify your quantity and click checkout',
      name: 'verify_your_quantity_and_click_checkout',
      desc: '',
      args: [],
    );
  }

  /// `Let's Start with Login!`
  String get lets_start_with_login {
    return Intl.message(
      'Let\'s Start with Login!',
      name: 'lets_start_with_login',
      desc: '',
      args: [],
    );
  }

  /// `Should be more than 3 characters`
  String get should_be_more_than_3_characters {
    return Intl.message(
      'Should be more than 3 characters',
      name: 'should_be_more_than_3_characters',
      desc: '',
      args: [],
    );
  }

  /// `You must add foods of the same restaurants choose one restaurants only!`
  String get you_must_add_foods_of_the_same_restaurants_choose_one {
    return Intl.message(
      'You must add foods of the same restaurants choose one restaurants only!',
      name: 'you_must_add_foods_of_the_same_restaurants_choose_one',
      desc: '',
      args: [],
    );
  }

  /// `Reset your cart and order meals form this restaurant`
  String get reset_your_cart_and_order_meals_form_this_restaurant {
    return Intl.message(
      'Reset your cart and order meals form this restaurant',
      name: 'reset_your_cart_and_order_meals_form_this_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Keep your old meals of this restaurant`
  String get keep_your_old_meals_of_this_restaurant {
    return Intl.message(
      'Keep your old meals of this restaurant',
      name: 'keep_your_old_meals_of_this_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Application Preferences`
  String get application_preferences {
    return Intl.message(
      'Application Preferences',
      name: 'application_preferences',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get help__support {
    return Intl.message(
      'Help & Support',
      name: 'help__support',
      desc: '',
      args: [],
    );
  }

  /// `Light Mode`
  String get light_mode {
    return Intl.message(
      'Light Mode',
      name: 'light_mode',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message(
      'Dark Mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get log_out {
    return Intl.message(
      'Log out',
      name: 'log_out',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `D'ont have any item in your cart`
  String get dont_have_any_item_in_your_cart {
    return Intl.message(
      'D\'ont have any item in your cart',
      name: 'dont_have_any_item_in_your_cart',
      desc: '',
      args: [],
    );
  }

  /// `Start Exploring`
  String get start_exploring {
    return Intl.message(
      'Start Exploring',
      name: 'start_exploring',
      desc: '',
      args: [],
    );
  }

  /// `D'ont have any item in the notification list`
  String get dont_have_any_item_in_the_notification_list {
    return Intl.message(
      'D\'ont have any item in the notification list',
      name: 'dont_have_any_item_in_the_notification_list',
      desc: '',
      args: [],
    );
  }

  /// `Payment Settings`
  String get payment_settings {
    return Intl.message(
      'Payment Settings',
      name: 'payment_settings',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid number`
  String get not_a_valid_number {
    return Intl.message(
      'Not a valid number',
      name: 'not_a_valid_number',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid date`
  String get not_a_valid_date {
    return Intl.message(
      'Not a valid date',
      name: 'not_a_valid_date',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid CVC`
  String get not_a_valid_cvc {
    return Intl.message(
      'Not a valid CVC',
      name: 'not_a_valid_cvc',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid full name`
  String get not_a_valid_full_name {
    return Intl.message(
      'Not a valid full name',
      name: 'not_a_valid_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get email_address {
    return Intl.message(
      'Email Address',
      name: 'email_address',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid email`
  String get not_a_valid_email {
    return Intl.message(
      'Not a valid email',
      name: 'not_a_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid phone`
  String get not_a_valid_phone {
    return Intl.message(
      'Not a valid phone',
      name: 'not_a_valid_phone',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid address`
  String get not_a_valid_address {
    return Intl.message(
      'Not a valid address',
      name: 'not_a_valid_address',
      desc: '',
      args: [],
    );
  }

  /// `Not a valid biography`
  String get not_a_valid_biography {
    return Intl.message(
      'Not a valid biography',
      name: 'not_a_valid_biography',
      desc: '',
      args: [],
    );
  }

  /// `Your biography`
  String get your_biography {
    return Intl.message(
      'Your biography',
      name: 'your_biography',
      desc: '',
      args: [],
    );
  }

  /// `Your Address`
  String get your_address {
    return Intl.message(
      'Your Address',
      name: 'your_address',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Recents Search`
  String get recents_search {
    return Intl.message(
      'Recents Search',
      name: 'recents_search',
      desc: '',
      args: [],
    );
  }

  /// `Verify your internet connection`
  String get verify_your_internet_connection {
    return Intl.message(
      'Verify your internet connection',
      name: 'verify_your_internet_connection',
      desc: '',
      args: [],
    );
  }

  /// `Carts refreshed successfully`
  String get carts_refreshed_successfuly {
    return Intl.message(
      'Carts refreshed successfully',
      name: 'carts_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `The $foodName was removed from your cart`
  String get the_food_was_removed_from_your_cart {
    return Intl.message(
      'The \$foodName was removed from your cart',
      name: 'the_food_was_removed_from_your_cart',
      desc: '',
      args: [],
    );
  }

  /// `Category refreshed successfully`
  String get category_refreshed_successfuly {
    return Intl.message(
      'Category refreshed successfully',
      name: 'category_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Notifications refreshed successfully`
  String get notifications_refreshed_successfuly {
    return Intl.message(
      'Notifications refreshed successfully',
      name: 'notifications_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Order refreshed successfully`
  String get order_refreshed_successfuly {
    return Intl.message(
      'Order refreshed successfully',
      name: 'order_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Orders refreshed successfully`
  String get orders_refreshed_successfuly {
    return Intl.message(
      'Orders refreshed successfully',
      name: 'orders_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant refreshed successfully`
  String get restaurant_refreshed_successfuly {
    return Intl.message(
      'Restaurant refreshed successfully',
      name: 'restaurant_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Profile settings updated successfully`
  String get profile_settings_updated_successfully {
    return Intl.message(
      'Profile settings updated successfully',
      name: 'profile_settings_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Payment settings updated successfully`
  String get payment_settings_updated_successfully {
    return Intl.message(
      'Payment settings updated successfully',
      name: 'payment_settings_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Tracking refreshed successfully`
  String get tracking_refreshed_successfuly {
    return Intl.message(
      'Tracking refreshed successfully',
      name: 'tracking_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Wrong email or password`
  String get wrong_email_or_password {
    return Intl.message(
      'Wrong email or password',
      name: 'wrong_email_or_password',
      desc: '',
      args: [],
    );
  }

  /// `Addresses refreshed successfuly`
  String get addresses_refreshed_successfuly {
    return Intl.message(
      'Addresses refreshed successfuly',
      name: 'addresses_refreshed_successfuly',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Addresses`
  String get delivery_addresses {
    return Intl.message(
      'Delivery Addresses',
      name: 'delivery_addresses',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `New Address added successfully`
  String get new_address_added_successfully {
    return Intl.message(
      'New Address added successfully',
      name: 'new_address_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `The address updated successfully`
  String get the_address_updated_successfully {
    return Intl.message(
      'The address updated successfully',
      name: 'the_address_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Long press to edit item, swipe item to delete it`
  String get long_press_to_edit_item_swipe_item_to_delete_it {
    return Intl.message(
      'Long press to edit item, swipe item to delete it',
      name: 'long_press_to_edit_item_swipe_item_to_delete_it',
      desc: '',
      args: [],
    );
  }

  /// `Add Delivery Address`
  String get add_delivery_address {
    return Intl.message(
      'Add Delivery Address',
      name: 'add_delivery_address',
      desc: '',
      args: [],
    );
  }

  /// `Home Address`
  String get home_address {
    return Intl.message(
      'Home Address',
      name: 'home_address',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `12 Street, City 21663, Country`
  String get hint_full_address {
    return Intl.message(
      '12 Street, City 21663, Country',
      name: 'hint_full_address',
      desc: '',
      args: [],
    );
  }

  /// `Full Address`
  String get full_address {
    return Intl.message(
      'Full Address',
      name: 'full_address',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message(
      'Orders',
      name: 'orders',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Mark as Delivered`
  String get delivered {
    return Intl.message(
      'Mark as Delivered',
      name: 'delivered',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Would you please confirm if you have delivered all meals to client`
  String get would_you_please_confirm_if_you_have_delivered_all_meals {
    return Intl.message(
      'Would you please confirm if you have delivered all meals to client',
      name: 'would_you_please_confirm_if_you_have_delivered_all_meals',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Confirmation`
  String get delivery_confirmation {
    return Intl.message(
      'Delivery Confirmation',
      name: 'delivery_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Foods Ordered`
  String get foods_ordered {
    return Intl.message(
      'Foods Ordered',
      name: 'foods_ordered',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get order_details {
    return Intl.message(
      'Order Details',
      name: 'order_details',
      desc: '',
      args: [],
    );
  }

  /// `Address not provided please call the client`
  String get address_not_provided_please_call_the_client {
    return Intl.message(
      'Address not provided please call the client',
      name: 'address_not_provided_please_call_the_client',
      desc: '',
      args: [],
    );
  }

  /// `Address not provided contact client`
  String get address_not_provided_contact_client {
    return Intl.message(
      'Address not provided contact client',
      name: 'address_not_provided_contact_client',
      desc: '',
      args: [],
    );
  }

  /// `Orders History`
  String get orders_history {
    return Intl.message(
      'Orders History',
      name: 'orders_history',
      desc: '',
      args: [],
    );
  }

  /// `Email to reset password`
  String get email_to_reset_password {
    return Intl.message(
      'Email to reset password',
      name: 'email_to_reset_password',
      desc: '',
      args: [],
    );
  }

  /// `Send link`
  String get send_password_reset_link {
    return Intl.message(
      'Send link',
      name: 'send_password_reset_link',
      desc: '',
      args: [],
    );
  }

  /// `I remember my password return to login`
  String get i_remember_my_password_return_to_login {
    return Intl.message(
      'I remember my password return to login',
      name: 'i_remember_my_password_return_to_login',
      desc: '',
      args: [],
    );
  }

  /// `Your reset link has been sent to your email`
  String get your_reset_link_has_been_sent_to_your_email {
    return Intl.message(
      'Your reset link has been sent to your email',
      name: 'your_reset_link_has_been_sent_to_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Error! Verify email settings`
  String get error_verify_email_settings {
    return Intl.message(
      'Error! Verify email settings',
      name: 'error_verify_email_settings',
      desc: '',
      args: [],
    );
  }

  /// `Order status changed`
  String get order_satatus_changed {
    return Intl.message(
      'Order status changed',
      name: 'order_satatus_changed',
      desc: '',
      args: [],
    );
  }

  /// `New Order from costumer`
  String get new_order_from_costumer {
    return Intl.message(
      'New Order from costumer',
      name: 'new_order_from_costumer',
      desc: '',
      args: [],
    );
  }

  /// `Your have an order assigned to you`
  String get your_have_an_order_assigned_to_you {
    return Intl.message(
      'Your have an order assigned to you',
      name: 'your_have_an_order_assigned_to_you',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message(
      'Unknown',
      name: 'unknown',
      desc: '',
      args: [],
    );
  }

  /// `Ordered Foods`
  String get ordered_foods {
    return Intl.message(
      'Ordered Foods',
      name: 'ordered_foods',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Fee`
  String get delivery_fee {
    return Intl.message(
      'Delivery Fee',
      name: 'delivery_fee',
      desc: '',
      args: [],
    );
  }

  /// `Items`
  String get items {
    return Intl.message(
      'Items',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any order assigned to you!`
  String get you_dont_have_any_order_assigned_to_you {
    return Intl.message(
      'You don\'t have any order assigned to you!',
      name: 'you_dont_have_any_order_assigned_to_you',
      desc: '',
      args: [],
    );
  }

  /// `Swipe left the notification to delete or read / unread it`
  String get swip_left_the_notification_to_delete_or_read__unread {
    return Intl.message(
      'Swipe left the notification to delete or read / unread it',
      name: 'swip_left_the_notification_to_delete_or_read__unread',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message(
      'Customer',
      name: 'customer',
      desc: '',
      args: [],
    );
  }

  /// `Km`
  String get km {
    return Intl.message(
      'Km',
      name: 'km',
      desc: '',
      args: [],
    );
  }

  /// `mi`
  String get mi {
    return Intl.message(
      'mi',
      name: 'mi',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `This account not exist`
  String get thisAccountNotExist {
    return Intl.message(
      'This account not exist',
      name: 'thisAccountNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Tap back again to leave`
  String get tapBackAgainToLeave {
    return Intl.message(
      'Tap back again to leave',
      name: 'tapBackAgainToLeave',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message(
      'Full Name',
      name: 'fullName',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Address`
  String get deliveryAddress {
    return Intl.message(
      'Delivery Address',
      name: 'deliveryAddress',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Complete`
  String get complete {
    return Intl.message(
      'Complete',
      name: 'complete',
      desc: '',
      args: [],
    );
  }

  /// `🔍 API Debug Info`
  String get api_debug_info {
    return Intl.message(
      '🔍 API Debug Info',
      name: 'api_debug_info',
      desc: '',
      args: [],
    );
  }

  /// `Configuration`
  String get configuration {
    return Intl.message(
      'Configuration',
      name: 'configuration',
      desc: '',
      args: [],
    );
  }

  /// `Testing`
  String get testing {
    return Intl.message(
      'Testing',
      name: 'testing',
      desc: '',
      args: [],
    );
  }

  /// `Test API Connection`
  String get test_api_connection {
    return Intl.message(
      'Test API Connection',
      name: 'test_api_connection',
      desc: '',
      args: [],
    );
  }

  /// `Testing Login`
  String get testing_login {
    return Intl.message(
      'Testing Login',
      name: 'testing_login',
      desc: '',
      args: [],
    );
  }

  /// `Test Login Endpoints`
  String get test_login_endpoints {
    return Intl.message(
      'Test Login Endpoints',
      name: 'test_login_endpoints',
      desc: '',
      args: [],
    );
  }

  /// `Test Results`
  String get test_results {
    return Intl.message(
      'Test Results',
      name: 'test_results',
      desc: '',
      args: [],
    );
  }

  /// `No message`
  String get no_message {
    return Intl.message(
      'No message',
      name: 'no_message',
      desc: '',
      args: [],
    );
  }

  /// `Response Preview`
  String get response_preview {
    return Intl.message(
      'Response Preview',
      name: 'response_preview',
      desc: '',
      args: [],
    );
  }

  /// `Endpoint Test Results`
  String get endpoint_test_results {
    return Intl.message(
      'Endpoint Test Results',
      name: 'endpoint_test_results',
      desc: '',
      args: [],
    );
  }

  /// `Unknown URL`
  String get unknown_url {
    return Intl.message(
      'Unknown URL',
      name: 'unknown_url',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Status`
  String get unknown_status {
    return Intl.message(
      'Unknown Status',
      name: 'unknown_status',
      desc: '',
      args: [],
    );
  }

  /// `Status Code`
  String get status_code {
    return Intl.message(
      'Status Code',
      name: 'status_code',
      desc: '',
      args: [],
    );
  }

  /// `Content Type`
  String get content_type {
    return Intl.message(
      'Content Type',
      name: 'content_type',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copied_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Suggestions`
  String get suggestions {
    return Intl.message(
      'Suggestions',
      name: 'suggestions',
      desc: '',
      args: [],
    );
  }

  /// `Issue Type:`
  String get issue_type {
    return Intl.message(
      'Issue Type:',
      name: 'issue_type',
      desc: '',
      args: [],
    );
  }

  /// `User Information`
  String get user_information {
    return Intl.message(
      'User Information',
      name: 'user_information',
      desc: '',
      args: [],
    );
  }

  /// `You have a new order!`
  String get you_have_a_new_order {
    return Intl.message(
      'You have a new order!',
      name: 'you_have_a_new_order',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get text {
    return Intl.message(
      'Text',
      name: 'text',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message(
      'Reject',
      name: 'reject',
      desc: '',
      args: [],
    );
  }

  /// `The order`
  String get the_order {
    return Intl.message(
      'The order',
      name: 'the_order',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `was accepted`
  String get was_accepted {
    return Intl.message(
      'was accepted',
      name: 'was_accepted',
      desc: '',
      args: [],
    );
  }

  /// `was rejected`
  String get was_rejected {
    return Intl.message(
      'was rejected',
      name: 'was_rejected',
      desc: '',
      args: [],
    );
  }

  /// `MMM dd, yyyy • HH:mm`
  String get date_format {
    return Intl.message(
      'MMM dd, yyyy • HH:mm',
      name: 'date_format',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get na {
    return Intl.message(
      'N/A',
      name: 'na',
      desc: '',
      args: [],
    );
  }

  /// `Ordered Items`
  String get ordered_items {
    return Intl.message(
      'Ordered Items',
      name: 'ordered_items',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Item`
  String get unknown_item {
    return Intl.message(
      'Unknown Item',
      name: 'unknown_item',
      desc: '',
      args: [],
    );
  }

  /// `Customer Information`
  String get customer_information {
    return Intl.message(
      'Customer Information',
      name: 'customer_information',
      desc: '',
      args: [],
    );
  }

  /// `Customer Name`
  String get customer_name {
    return Intl.message(
      'Customer Name',
      name: 'customer_name',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phone_number {
    return Intl.message(
      'Phone Number',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Address`
  String get delivery_address {
    return Intl.message(
      'Delivery Address',
      name: 'delivery_address',
      desc: '',
      args: [],
    );
  }

  /// `Order Summary`
  String get order_summary {
    return Intl.message(
      'Order Summary',
      name: 'order_summary',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message(
      'Cash',
      name: 'cash',
      desc: '',
      args: [],
    );
  }

  /// `✅ Order Delivered Successfully`
  String get order_delivered_successfully {
    return Intl.message(
      '✅ Order Delivered Successfully',
      name: 'order_delivered_successfully',
      desc: '',
      args: [],
    );
  }

  /// `🚗 Start Delivery`
  String get start_delivery {
    return Intl.message(
      '🚗 Start Delivery',
      name: 'start_delivery',
      desc: '',
      args: [],
    );
  }

  /// `✅ Mark as Delivered`
  String get mark_as_delivered {
    return Intl.message(
      '✅ Mark as Delivered',
      name: 'mark_as_delivered',
      desc: '',
      args: [],
    );
  }

  /// `Start Delivery?`
  String get start_delivery_question {
    return Intl.message(
      'Start Delivery?',
      name: 'start_delivery_question',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delivery?`
  String get confirm_delivery_question {
    return Intl.message(
      'Confirm Delivery?',
      name: 'confirm_delivery_question',
      desc: '',
      args: [],
    );
  }

  /// `Mark this order as 'On The Way' to customer?`
  String get mark_on_the_way_question {
    return Intl.message(
      'Mark this order as \'On The Way\' to customer?',
      name: 'mark_on_the_way_question',
      desc: '',
      args: [],
    );
  }

  /// `Confirm that you have delivered all items to the customer?`
  String get confirm_all_items_delivered_question {
    return Intl.message(
      'Confirm that you have delivered all items to the customer?',
      name: 'confirm_all_items_delivered_question',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `LIVE`
  String get live {
    return Intl.message(
      'LIVE',
      name: 'live',
      desc: '',
      args: [],
    );
  }

  /// `Last updated`
  String get last_updated {
    return Intl.message(
      'Last updated',
      name: 'last_updated',
      desc: '',
      args: [],
    );
  }

  /// `Auto-refresh: ON`
  String get auto_refresh_on {
    return Intl.message(
      'Auto-refresh: ON',
      name: 'auto_refresh_on',
      desc: '',
      args: [],
    );
  }

  /// `Driver Status`
  String get driver_status {
    return Intl.message(
      'Driver Status',
      name: 'driver_status',
      desc: '',
      args: [],
    );
  }

  /// `🚚 Delivery Orders`
  String get delivery_orders {
    return Intl.message(
      '🚚 Delivery Orders',
      name: 'delivery_orders',
      desc: '',
      args: [],
    );
  }

  /// `AVAILABLE`
  String get available {
    return Intl.message(
      'AVAILABLE',
      name: 'available',
      desc: '',
      args: [],
    );
  }

  /// `OFFLINE`
  String get offline {
    return Intl.message(
      'OFFLINE',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `You're online and ready to receive orders`
  String get online_ready {
    return Intl.message(
      'You\'re online and ready to receive orders',
      name: 'online_ready',
      desc: '',
      args: [],
    );
  }

  /// `You're offline and won't receive new orders`
  String get offline_not_receiving {
    return Intl.message(
      'You\'re offline and won\'t receive new orders',
      name: 'offline_not_receiving',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `View active orders`
  String get view_active_orders {
    return Intl.message(
      'View active orders',
      name: 'view_active_orders',
      desc: '',
      args: [],
    );
  }

  /// `Check alerts`
  String get check_alerts {
    return Intl.message(
      'Check alerts',
      name: 'check_alerts',
      desc: '',
      args: [],
    );
  }

  /// `Past deliveries`
  String get past_deliveries {
    return Intl.message(
      'Past deliveries',
      name: 'past_deliveries',
      desc: '',
      args: [],
    );
  }

  /// `Get assistance`
  String get get_assistance {
    return Intl.message(
      'Get assistance',
      name: 'get_assistance',
      desc: '',
      args: [],
    );
  }

  /// `App preferences`
  String get app_preferences {
    return Intl.message(
      'App preferences',
      name: 'app_preferences',
      desc: '',
      args: [],
    );
  }

  /// `Change language`
  String get change_language {
    return Intl.message(
      'Change language',
      name: 'change_language',
      desc: '',
      args: [],
    );
  }

  /// `Debug Info`
  String get debug_info {
    return Intl.message(
      'Debug Info',
      name: 'debug_info',
      desc: '',
      args: [],
    );
  }

  /// `API & Token diagnostics`
  String get api_token_diagnostics {
    return Intl.message(
      'API & Token diagnostics',
      name: 'api_token_diagnostics',
      desc: '',
      args: [],
    );
  }

  /// `ACTIVE DRIVER`
  String get active_driver {
    return Intl.message(
      'ACTIVE DRIVER',
      name: 'active_driver',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Switch to light theme`
  String get switch_to_light_theme {
    return Intl.message(
      'Switch to light theme',
      name: 'switch_to_light_theme',
      desc: '',
      args: [],
    );
  }

  /// `Switch to dark theme`
  String get switch_to_dark_theme {
    return Intl.message(
      'Switch to dark theme',
      name: 'switch_to_dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logout_confirmation {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logout_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Sign out of your account`
  String get sign_out_account {
    return Intl.message(
      'Sign out of your account',
      name: 'sign_out_account',
      desc: '',
      args: [],
    );
  }

  /// `App Version`
  String get app_version {
    return Intl.message(
      'App Version',
      name: 'app_version',
      desc: '',
      args: [],
    );
  }

  /// `Go To Home`
  String get go_to_home {
    return Intl.message(
      'Go To Home',
      name: 'go_to_home',
      desc: '',
      args: [],
    );
  }

  /// `Looking for new orders...`
  String get looking_for_new_orders {
    return Intl.message(
      'Looking for new orders...',
      name: 'looking_for_new_orders',
      desc: '',
      args: [],
    );
  }

  /// `Searching for New Orders...`
  String get searching_for_new_orders {
    return Intl.message(
      'Searching for New Orders...',
      name: 'searching_for_new_orders',
      desc: '',
      args: [],
    );
  }

  /// `No New Orders Available`
  String get no_new_orders_available {
    return Intl.message(
      'No New Orders Available',
      name: 'no_new_orders_available',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while we check for delivery requests...`
  String get please_wait_checking_requests {
    return Intl.message(
      'Please wait while we check for delivery requests...',
      name: 'please_wait_checking_requests',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for new delivery requests...\nPull down to refresh or check your availability status.`
  String get waiting_for_new_requests {
    return Intl.message(
      'Waiting for new delivery requests...\nPull down to refresh or check your availability status.',
      name: 'waiting_for_new_requests',
      desc: '',
      args: [],
    );
  }

  /// `Refresh Orders`
  String get refresh_orders {
    return Intl.message(
      'Refresh Orders',
      name: 'refresh_orders',
      desc: '',
      args: [],
    );
  }

  /// `NEW ORDER`
  String get new_order {
    return Intl.message(
      'NEW ORDER',
      name: 'new_order',
      desc: '',
      args: [],
    );
  }

  /// `🔥 HOT`
  String get hot {
    return Intl.message(
      '🔥 HOT',
      name: 'hot',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error rejecting order`
  String get error_rejecting_order {
    return Intl.message(
      '❌ Error rejecting order',
      name: 'error_rejecting_order',
      desc: '',
      args: [],
    );
  }

  /// `ACCEPTING...`
  String get accepting {
    return Intl.message(
      'ACCEPTING...',
      name: 'accepting',
      desc: '',
      args: [],
    );
  }

  /// `Ready to become a Carry courier partner?`
  String get sentence1 {
    return Intl.message(
      'Ready to become a Carry courier partner?',
      name: 'sentence1',
      desc: '',
      args: [],
    );
  }

  /// `Before we get you started as a Carry courier partner, we just need a few details from you.Fill out the quick application below, and we'll get the ball rolling!`
  String get sentence2 {
    return Intl.message(
      'Before we get you started as a Carry courier partner, we just need a few details from you.Fill out the quick application below, and we\'ll get the ball rolling!',
      name: 'sentence2',
      desc: '',
      args: [],
    );
  }

  /// `Carry`
  String get carry {
    return Intl.message(
      'Carry',
      name: 'carry',
      desc: '',
      args: [],
    );
  }

  /// `PARTNER`
  String get partner {
    return Intl.message(
      'PARTNER',
      name: 'partner',
      desc: '',
      args: [],
    );
  }

  /// `That's it!`
  String get thats_it {
    return Intl.message(
      'That\'s it!',
      name: 'thats_it',
      desc: '',
      args: [],
    );
  }

  /// `Thank you, we're excited to review your application as soon as possible.`
  String get thank_you_application {
    return Intl.message(
      'Thank you, we\'re excited to review your application as soon as possible.',
      name: 'thank_you_application',
      desc: '',
      args: [],
    );
  }

  /// `We'll be in touch with you shortly.`
  String get we_ll_be_in_touch {
    return Intl.message(
      'We\'ll be in touch with you shortly.',
      name: 'we_ll_be_in_touch',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get Continue {
    return Intl.message(
      'Continue',
      name: 'Continue',
      desc: '',
      args: [],
    );
  }

  /// `Personal data policy`
  String get personal_data_policy {
    return Intl.message(
      'Personal data policy',
      name: 'personal_data_policy',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to become a Carry courier partner?`
  String get would_you_like {
    return Intl.message(
      'Would you like to become a Carry courier partner?',
      name: 'would_you_like',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get hello {
    return Intl.message(
      'Hello',
      name: 'hello',
      desc: '',
      args: [],
    );
  }

  /// `Please follow the steps below to make that magic happen.`
  String get please_follow_steps {
    return Intl.message(
      'Please follow the steps below to make that magic happen.',
      name: 'please_follow_steps',
      desc: '',
      args: [],
    );
  }

  /// `Send application`
  String get send_application {
    return Intl.message(
      'Send application',
      name: 'send_application',
      desc: '',
      args: [],
    );
  }

  /// `APPROVED`
  String get approved {
    return Intl.message(
      'APPROVED',
      name: 'approved',
      desc: '',
      args: [],
    );
  }

  /// `Contract`
  String get contract {
    return Intl.message(
      'Contract',
      name: 'contract',
      desc: '',
      args: [],
    );
  }

  /// `Please fill the information needed for making a Courier partner contract with Carry.`
  String get please_fill_info {
    return Intl.message(
      'Please fill the information needed for making a Courier partner contract with Carry.',
      name: 'please_fill_info',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get contact_support {
    return Intl.message(
      'Contact support',
      name: 'contact_support',
      desc: '',
      args: [],
    );
  }

  /// `We will get back to you as soon as possible`
  String get we_will_get_back {
    return Intl.message(
      'We will get back to you as soon as possible',
      name: 'we_will_get_back',
      desc: '',
      args: [],
    );
  }

  /// `Select your Nationality`
  String get select_nationality_title {
    return Intl.message(
      'Select your Nationality',
      name: 'select_nationality_title',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your nationality to help us verify your identity documents. For instance, if you hold a German passport, select 'Germany' as your country of nationality.`
  String get select_nationality_description {
    return Intl.message(
      'Please confirm your nationality to help us verify your identity documents. For instance, if you hold a German passport, select \'Germany\' as your country of nationality.',
      name: 'select_nationality_description',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'he'),
      Locale.fromSubtags(languageCode: 'pt'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
