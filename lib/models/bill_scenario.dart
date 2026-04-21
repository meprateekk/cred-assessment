enum BillScenario { twoItems, manyItems }

extension BillScenarioX on BillScenario {
  String get endpoint {
    switch (this) {
      case BillScenario.twoItems:
        return 'https://api.mocklets.com/p26/mock1';
      case BillScenario.manyItems:
        return 'https://api.mocklets.com/p26/mock2';
    }
  }

  String get label {
    switch (this) {
      case BillScenario.twoItems:
        return '2 items';
      case BillScenario.manyItems:
        return '9 items';
    }
  }

  String get description {
    switch (this) {
      case BillScenario.twoItems:
        return 'Static stacked preview for the compact state';
      case BillScenario.manyItems:
        return 'Swipeable vertical carousel for the full state';
    }
  }
}
