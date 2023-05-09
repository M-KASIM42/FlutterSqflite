import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        debugShowCheckedModeBanner: false,
        title: 'Veri tabanı',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  List<Map<String, dynamic>> _journals = [];

bool _isLoading = true;

void _refreshJournals() async {
  // TODO listedeki bütün elemanları getirin.
  List<Map<String, dynamic>> items = await DbHelper().getItems();
  setState(() {
    _journals = items;
    _isLoading = false;
  });
}



  @override
  void initState() {
    super.initState();
    _refreshJournals();
    debugPrint(_journals.toString());
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
      _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {

                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }


                  _titleController.text = '';
                  _descriptionController.text = '';


                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }


  Future<void> _addItem() async {
    // TODO eleman oluşturma fonksiyonunu çağırınız
    DbHelper().addItem({'title':_titleController.text,'description':_descriptionController.text});
    _refreshJournals();
  }


  Future<void> _updateItem(int id) async {
    // TODO eleman güncelleme fonksiyonunu çağırınız
    await DbHelper().updateItem({'id':id,'title':_titleController.text,'description':_descriptionController.text});
    _refreshJournals();
  }


  void _deleteItem(int id) async {
    await DbHelper().deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veri Tabanı'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.blue,
          margin: const EdgeInsets.all(15),
          child: ListTile(
              title: Text(_journals[index]['title']),
              subtitle: Text(_journals[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: ()async{
                        _showForm(index);
                        await _updateItem(index);
                      },
                      // TODO güncelleme işlemini gerçekleştirmesini sağlayınız.
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      // TODO silme işlemni gerçekleştirmesini sağlayınız.
                      onPressed: (){
                        setState(() {
                          _deleteItem(index + 1);
                        });
                         
                      },
                    ),
                  ],
                ),
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}