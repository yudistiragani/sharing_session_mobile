part of 'user_home_bloc.dart';

abstract class UserHomeEvent {}

class UserHomeStarted extends UserHomeEvent {}

class UserHomeSearchChanged extends UserHomeEvent {
  final String? search;
  UserHomeSearchChanged(this.search);
}

class UserHomeRefreshed extends UserHomeEvent {}
