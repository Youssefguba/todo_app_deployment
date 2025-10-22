enum Flavor {
  dev,
  stg,
  prod,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Todo App Dev';
      case Flavor.stg:
        return 'Todo App Stg';
      case Flavor.prod:
        return 'Todo App';
    }
  }

}
