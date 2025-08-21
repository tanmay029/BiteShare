// lib/app/modules/recipe/widgets/rating_dialog.dart
import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String recipeId;
  final Function(int) onRated;
  
  const RatingDialog({
    Key? key, 
    required this.recipeId, 
    required this.onRated
  }) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate this Recipe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How would you rate this recipe?'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(10, (index) {
              int rating = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRating = rating;
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selectedRating >= rating ? Colors.orange : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rating',
                      style: TextStyle(
                        color: selectedRating >= rating ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedRating > 0 ? () {
            widget.onRated(selectedRating);
            Navigator.pop(context);
          } : null,
          child: const Text('Rate'),
        ),
      ],
    );
  }
}
