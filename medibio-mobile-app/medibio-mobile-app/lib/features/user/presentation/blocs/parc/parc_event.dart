abstract class ParcEvent {}


class LoadAllParcs extends ParcEvent {}


class LoadParcs extends ParcEvent {
  final String interventionId;

  LoadParcs(this.interventionId);
}


class LoadAllArticles extends ParcEvent {}
