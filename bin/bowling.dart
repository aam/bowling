import 'package:unittest/unittest.dart';

class Game {
  int cFrame = 0;
  bool secondRoll = false;
  
  List<int> pendingOnes = new List<int>();
  int pendingTwo;
  
  List<int> frames = new List<int>(10+2);
  
  String log = "";
  
  Game() {
    frames.fillRange(0, frames.length, 0);
  }
  
  int get score {
    return frames.fold(0, (sum, frame) => sum + frame);
  }
  
  bool isComplete = false;
  
  roll(int pinsDown) {
    if (pinsDown < 0 || pinsDown > 10) {
      throw new ArgumentError('Invalid number of pins reported down');
    }
    frames[cFrame] += pinsDown;
    if (frames[cFrame] > 10) {
      throw new ArgumentError('Ended up downing more than 10 pins');
    }
    for (int pendingOneFrame in pendingOnes) {
      frames[pendingOneFrame] += pinsDown;
    }
    pendingOnes.clear();
    if (pendingTwo != null) {
      pendingOnes.add(pendingTwo);
      pendingTwo = null;
    }
    
    if (frames[cFrame] == 10) {
      if (!secondRoll) {
        pendingTwo = cFrame;
        log += "X ";
      }
      else {
        log += "/ ";
      }
      pendingOnes.add(cFrame);
      secondRoll = false;
      cFrame++;
    }
    else {
      log += pinsDown == 0? "-": "$pinsDown";
      if (secondRoll) {
        secondRoll = false;
        log += " ";
        cFrame++;
      } else {
        secondRoll = true;
      }
    }
  }
  
  String toString() {
    String string = log;
    if (cFrame < 10) {
      for (int i = cFrame + 1; i < 10; i++) {
        string += "-- ";
      }
      string += "--- =";
    }
    return string;
  }
}

void main() {
  test('IntialScore', () =>
      expect(new Game().score, 0));
  test('RollZero', () =>
      expect((new Game()..roll(0)).score, 0, reason: 'Score should be 0'));
  test('RollOne', () =>
      expect((new Game()..roll(1)).score, 1, reason: 'Score should be 1'));
  
  test('RollNegative', () {
      expect(() => new Game()..roll(-1),
        throwsArgumentError);
  });
  test('RollEleven', () {
      expect(() => new Game()..roll(11),
        throwsArgumentError);
  });
  
  test('TwoRollsZero', () =>
      expect((new Game()..roll(0)..roll(0)).score, 0, reason: 'Score should be 0'));
  test('TwoRollsThree', () =>
      expect((new Game()..roll(1)..roll(2)).score, 3, reason: 'Score should be 3'));

  test('TwoFrames', () =>
      expect((new Game()..roll(1)
                        ..roll(2)
                        ..roll(3)
                        ..roll(4)).score, 10, reason: 'Score should be 10'));
  test('TwoFramesSpare', () =>
      expect((new Game()..roll(1)
                        ..roll(9)
                        ..roll(3)
                        ..roll(4)).score, 20, reason: 'Score should be 20'));
  test('TwoFramesStrike', () =>
      expect((new Game()..roll(10)
                        ..roll(3)
                        ..roll(4)).score, 24, reason: 'Score should be 24'));
  test('ThreeFramesSpare', ()  =>
      expect((new Game()..roll(1)
                        ..roll(9)
                        ..roll(3)
                        ..roll(4)
                        ..roll(5)
                        ..roll(4)).score, 29, reason: 'Score should be 29'));
  test('ThreeFramesSpareStrike', ()  =>
      expect((new Game()..roll(1)
                        ..roll(9)
                        ..roll(10)
                        ..roll(5)
                        ..roll(4)).score, 48, reason: 'Score should be 48'));
  test('ThreeFramesStrikeSpare', ()  =>
      expect((new Game()..roll(10)
                        ..roll(9)
                        ..roll(1)
                        ..roll(4)).score, 38, reason: 'Score should be 38'));
  test('ThreeFramesTwoSpares', ()  =>
      expect((new Game()..roll(1)
                        ..roll(9)
                        ..roll(3)
                        ..roll(7)
                        ..roll(5)
                        ..roll(4)).score, 37, reason: 'Score should be 37'));
  test('ThreeFramesTwoStrikes', () {
    Game game = (new Game()..roll(10)
                           ..roll(10)
                           ..roll(9)
                           ..roll(0));
    expect(game.score, 57, reason: 'Score should be 57');
    expect(game.isComplete, false, reason: 'Game should not be complete');
  });
  
  test('TwoRollsEleven', () {
    expect(() => new Game()..roll(5)
                           ..roll(6),
        throwsArgumentError);
  });
  
  test('PrintGame', () {
    expect((new Game()..roll(1)
                      ..roll(2)
                      ..roll(3)
                      ..roll(7)
                      ..roll(4)
                      ..roll(6)
                      ..roll(5)
                      ..roll(0)
                      ..roll(10)
                      ..roll(8)
                      ..roll(0)
                      ..roll(0)
                      ..roll(9)).toString(), "12 3/ 4/ 5- X 8- -9 -- -- --- =", reason: "Game log should be correct");
    });
}


