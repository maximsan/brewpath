import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('displayedTreeStage', () {
    test('clamps a fresh install (stage 0) to the seed', () {
      expect(displayedTreeStage(0), 1);
    });

    test('passes stages within the shipped frames through unchanged', () {
      expect(displayedTreeStage(1), 1);
      expect(displayedTreeStage(5), 5);
      expect(displayedTreeStage(10), 10);
    });

    test('clamps a stage above the shipped frames to full growth', () {
      expect(displayedTreeStage(12), 10);
    });
  });

  group('treeStageAsset', () {
    test('names the frame for the displayed stage', () {
      expect(treeStageAsset(7), 'assets/images/trees/7.png');
    });

    test('resolves stage 0 to the seed frame', () {
      expect(treeStageAsset(0), 'assets/images/trees/1.png');
    });
  });

  group('treeStageLabel', () {
    test('names the displayed stage out of ten', () {
      expect(treeStageLabel(7), 'Your coffee tree, stage 7 of 10');
    });

    test('reads the seed for a fresh install', () {
      expect(treeStageLabel(0), 'Your coffee tree, stage 1 of 10');
    });
  });
}
