// lib/app/modules/recipe/create_recipe_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/recipe_controller.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/firebase_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientController = TextEditingController();
  final _tagController = TextEditingController();
  
  final List<String> _ingredients = [];
  final List<RecipeStep> _steps = [];
  final List<String> _tags = [];
  final List<File> _mediaFiles = [];
  
  bool _isPremium = false;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final RecipeController _recipeController = Get.find<RecipeController>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Post'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Upload Section
              _buildMediaSection(),
              const SizedBox(height: 20),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Ingredients Section
              _buildIngredientsSection(),
              const SizedBox(height: 20),
              
              // Steps Section
              _buildStepsSection(),
              const SizedBox(height: 20),
              
              // Tags Section
              _buildTagsSection(),
              const SizedBox(height: 20),
              
              // Premium Toggle
              SwitchListTile(
                title: const Text('Premium Recipe'),
                subtitle: const Text('Only subscribers can view this recipe'),
                value: _isPremium,
                onChanged: (value) {
                  setState(() {
                    _isPremium = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Media', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        if (_mediaFiles.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaFiles.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Image.file(
                        _mediaFiles[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _mediaFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photo'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Add Video'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ingredientController,
                decoration: const InputDecoration(
                  hintText: 'Add ingredient',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addIngredient,
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_ingredients.isNotEmpty)
          Column(
            children: _ingredients.map((ingredient) {
              int index = _ingredients.indexOf(ingredient);
              return ListTile(
                title: Text(ingredient),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _ingredients.removeAt(index);
                    });
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Steps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: _addStep,
              child: const Text('Add Step'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_steps.isNotEmpty)
          Column(
            children: _steps.map((step) {
              int index = _steps.indexOf(step);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${step.stepNumber}')),
                  title: Text(step.instruction),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _steps.removeAt(index);
                        // Renumber steps
                        for (int i = 0; i < _steps.length; i++) {
                          _steps[i] = RecipeStep(
                            stepNumber: i + 1,
                            instruction: _steps[i].instruction,
                            image: _steps[i].image,
                          );
                        }
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add tag (e.g., vegetarian, spicy)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addTag,
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8.0,
            children: _tags.map((tag) {
              return Chip(
                label: Text('#$tag'),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mediaFiles.add(File(image.path));
      });
    }
  }

  void _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _mediaFiles.add(File(video.path));
      });
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) {
        final stepController = TextEditingController();
        return AlertDialog(
          title: Text('Add Step ${_steps.length + 1}'),
          content: TextField(
            controller: stepController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter step instruction',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (stepController.text.isNotEmpty) {
                  setState(() {
                    _steps.add(RecipeStep(
                      stepNumber: _steps.length + 1,
                      instruction: stepController.text,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        Get.snackbar('Error', 'Please add at least one ingredient');
        return;
      }
      if (_steps.isEmpty) {
        Get.snackbar('Error', 'Please add at least one step');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Upload media files
        List<MediaItem> mediaItems = [];
        for (File file in _mediaFiles) {
          String url = await _firebaseService.uploadImage(file, 'recipes');
          mediaItems.add(MediaItem(
            url: url,
            type: MediaType.image, // Determine type based on file extension
          ));
        }

        // Create recipe
        String recipeId = await _recipeController.createRecipe(
          title: _titleController.text,
          description: _descriptionController.text,
          ingredients: _ingredients,
          steps: _steps,
          tags: _tags,
          media: mediaItems,
          isPremium: _isPremium,
        );

        Get.back();
        Get.snackbar('Success', 'Recipe created successfully!');
      } catch (e) {
        Get.snackbar('Error', 'Failed to create recipe: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
