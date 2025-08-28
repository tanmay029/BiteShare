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
  final List<File> _mediaFiles = []; // Optional - can be empty
  
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
              // ✅ UPDATED: Optional Media Upload Section
              _buildOptionalMediaSection(),
              const SizedBox(height: 20),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title *',
                  border: OutlineInputBorder(),
                  helperText: 'Required',
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
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  helperText: 'Required',
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
              
              // Tags Section (Optional)
              _buildOptionalTagsSection(),
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
              
              const SizedBox(height: 20),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Recipe Requirements',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('• Title and description are required'),
                    const Text('• At least one ingredient is required'),
                    const Text('• At least one cooking step is required'),
                    const Text('• Images and tags are optional'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Optional Media Section
  Widget _buildOptionalMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recipe Images', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_mediaFiles.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaFiles.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _mediaFiles[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mediaFiles.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
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
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(_mediaFiles.isEmpty ? 'Add Photos (Optional)' : 'Add More Photos'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Add Video'),
            ),
          ],
        ),
        
        if (_mediaFiles.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'You can add photos to make your recipe more appealing, but it\'s not required.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  // ✅ UPDATED: Optional Tags Section
  Widget _buildOptionalTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tags', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Optional',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add tags (e.g., vegetarian, spicy, quick)',
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
          )
        else
          Text(
            'Tags help users discover your recipe. Add keywords like "quick", "healthy", or "vegetarian".',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredients *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                leading: CircleAvatar(
                  radius: 12,
                  child: Text('${index + 1}'),
                ),
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
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'No ingredients added yet. Add at least one ingredient to continue.',
              style: TextStyle(color: Colors.grey),
            ),
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
            const Text('Cooking Steps *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Text(
              'No cooking steps added yet. Add at least one step to continue.',
              style: TextStyle(color: Colors.grey),
            ),
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
        _tags.add(_tagController.text.toLowerCase().replaceAll(' ', '-'));
        _tagController.clear();
      });
    }
  }

  // ✅ UPDATED: Save Recipe with Optional Images
  void _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      // Check required fields
      if (_ingredients.isEmpty) {
        Get.snackbar('Error', 'Please add at least one ingredient');
        return;
      }
      if (_steps.isEmpty) {
        Get.snackbar('Error', 'Please add at least one cooking step');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // ✅ UPDATED: Handle optional media upload
        List<MediaItem> mediaItems = [];
        
        if (_mediaFiles.isNotEmpty) {
          print('Uploading ${_mediaFiles.length} media files...');
          
          for (int i = 0; i < _mediaFiles.length; i++) {
            File file = _mediaFiles[i];
            print('Uploading file ${i + 1}/${_mediaFiles.length}: ${file.path}');
            
            // Check if file exists before uploading
            if (!await file.exists()) {
              throw Exception('File does not exist: ${file.path}');
            }
            
            try {
              String url = await _firebaseService.uploadImage(file, 'recipes');
              print('Successfully uploaded file ${i + 1}: $url');
              
              mediaItems.add(MediaItem(
                url: url,
                type: MediaType.image, // Determine based on file extension
              ));
            } catch (uploadError) {
              print('Error uploading file ${i + 1}: $uploadError');
              throw Exception('Failed to upload image ${i + 1}: $uploadError');
            }
          }
        } else {
          print('No media files to upload - creating recipe without images');
        }

        // Create recipe (with or without media)
        String recipeId = await _recipeController.createRecipe(
          title: _titleController.text,
          description: _descriptionController.text,
          ingredients: _ingredients,
          steps: _steps,
          tags: _tags,
          media: mediaItems, // Can be empty list
          isPremium: _isPremium,
        );

        Get.back();
        String successMessage = mediaItems.isEmpty 
            ? 'Recipe created successfully!'
            : 'Recipe created with ${mediaItems.length} image(s)!';
        Get.snackbar('Success', successMessage);
        
      } catch (e) {
        print('Recipe creation error: $e');
        Get.snackbar('Error', 'Failed to create recipe: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
