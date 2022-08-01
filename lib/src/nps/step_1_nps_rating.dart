import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/core/wiredash_model_provider.dart';
import 'package:wiredash/src/utils/delay.dart';
import 'package:wiredash/src/nps/nps_model.dart';
import 'package:wiredash/src/nps/nps_model_provider.dart';
import 'package:wiredash/src/utils/standard_kt.dart';

class NpsStep1 extends StatelessWidget {
  const NpsStep1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StepPageScaffold(
      title: Text(context.l10n.npsStep1Question),
      onClose: () {
        context.wiredashModel.hide(discardNps: true);
      },
      indicator: const StepIndicator(
        completed: false,
        currentStep: 1,
        total: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.npsStep1Description),
          const SizedBox(height: 32),
          _NpsRater(
            score: context.npsModel.score?.intValue,
            onSelected: (score) {
              final rating = score?.let((it) => createNpsRating(it));
              context.npsModel.score = rating;
              if (rating != null) {
                widgetsBindingInstance.addPostFrameCallback((_) {
                  context
                      .findAncestorStateOfType<LarryPageViewState>()!
                      .moveToNextPage();
                });
              }
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TronButton(
                label: context.l10n.npsNextButton,
                trailingIcon: Wirecons.arrow_right,
                onTap: context.npsModel.score != null
                    ? () {
                        context
                            .findAncestorStateOfType<LarryPageViewState>()!
                            .moveToNextPage();
                      }
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _NpsRater extends StatefulWidget {
  const _NpsRater({
    Key? key,
    required this.score,
    required this.onSelected,
  }) : super(key: key);

  final void Function(int? score) onSelected;
  final int? score;

  @override
  State<_NpsRater> createState() => _NpsRaterState();
}

class _NpsRaterState extends State<_NpsRater> {
  Delay? _selectionDelay;

  // score between pressed and submitted to callback
  int? _inflightScore;

  void _onTap(int score) {
    setState(() {
      if ((_inflightScore ?? widget.score) == score) {
        _inflightScore = null;
      } else {
        _inflightScore = score;
      }
    });
    _fire();
  }

  Future<void> _fire() async {
    _selectionDelay?.dispose();
    _selectionDelay = Delay(const Duration(milliseconds: 400));
    await _selectionDelay!.future;
    if (!mounted) return;
    widget.onSelected.call(_inflightScore);
    _inflightScore = null;
  }

  @override
  void dispose() {
    super.dispose();
    _selectionDelay?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: context.theme.windowSize.width > 800
          ? Alignment.centerLeft
          : Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxItemWidth = constraints.maxWidth / 6;
          final selectedScore = _inflightScore ?? widget.score;
          return Wrap(
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final i in [0, 1, 2, 3, 4, 5])
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxItemWidth),
                      child: _RatingCard(
                        value: i,
                        checked: i == selectedScore,
                        onTap: () => _onTap(i),
                      ),
                    ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final i in [6, 7, 8, 9, 10])
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxItemWidth),
                      child: _RatingCard(
                        value: i,
                        checked: i == selectedScore,
                        onTap: () => _onTap(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingCard extends StatefulWidget {
  const _RatingCard({
    Key? key,
    required this.value,
    required this.checked,
    required this.onTap,
  }) : super(key: key);

  final int value;
  final bool checked;
  final void Function() onTap;

  @override
  _RatingCardState createState() => _RatingCardState();
}

class _RatingCardState extends State<_RatingCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.value == 3) {
      print(
          'build _RatingCardState{value: ${widget.value}, checked: ${widget.checked}}');
    }
    const animDuration = Duration(milliseconds: 250);

    final borderTween = BorderTween(
      begin: Border.fromBorderSide(
        BorderSide(
          color: context.theme.primaryColor.withOpacity(0.25),
          width: 2,
        ),
      ),
      end: Border.fromBorderSide(
        BorderSide(
          color: context.theme.primaryColor.withOpacity(1.0),
          width: 2,
        ),
      ),
    );
    return AnimatedClickTarget(
      onTap: widget.onTap,
      selected: widget.checked,
      duration: animDuration,
      builder: (context, state, anims) {
        final theme = context.theme;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: () {
              final hover = anims.hoveredAnim.value * 0.5;
              final selected = anims.selectedAnim.value * 0.8;
              double combined = 0.0;
              if (anims.hoveredAnim.value > 0 && anims.selectedAnim.value > 0) {
                combined = anims.hoveredAnim.value * 0.5 +
                    anims.selectedAnim.value * 0.5;
              }

              final t = max(combined, max(hover, selected));
              return borderTween.transform(t)!.top;
            }(),
          ),
          color: theme.primaryBackgroundColor,
          child: SizedBox(
            width: 48,
            height: 60,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: AnimatedDefaultTextStyle(
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        color: widget.checked
                            ? theme.primaryTextOnBackgroundColor
                            : theme.secondaryTextOnBackgroundColor,
                      ),
                      duration: animDuration,
                      child: Text(widget.value.toString()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: animDuration * 2,
                    child: Icon(
                      widget.checked ? Wirecons.check_circle : Wirecons.circle,
                      key: ValueKey(widget.checked),
                      color: theme.primaryColor
                          .withOpacity(widget.checked ? 1.0 : 0.5),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
