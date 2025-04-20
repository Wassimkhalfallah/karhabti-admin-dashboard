import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/feedback_model.dart';
import '../../widgets/stat_card.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedCategory = 'Tous';
  int _selectedIndex = -1;
  
  final List<String> _categories = ['Tous', 'Non lus', 'En attente', 'Ru00e9pondus', 'Archivu00e9s'];
  
  // Donnu00e9es de du00e9monstration pour les messages
  List<Map<String, dynamic>> _messages = [];
  
  @override
  void initState() {
    super.initState();
    _generateDummyMessages();
  }
  
  void _generateDummyMessages() {
    final subjects = [
      'Problu00e8me avec l\'application',
      'Question sur la vidange',
      'Pru00e9diction de panne erronu00e9e',
      'Suggestion d\'amu00e9lioration',
      'Remerciements',
      'Pru00e9cision sur les freins',
      'Demande de fonctionnalitu00e9',
      'Problu00e8me d\'enregistrement',
      'Bug dans l\'interface',
      'Question sur la batterie',
    ];
    
    final clientNames = ['Mohamed A.', 'Sarah B.', 'Ahmed C.', 'Amina D.', 'Karim E.', 'Leila F.', 'Youssef G.', 'Yasmine H.', 'Ali I.', 'Nour J.'];
    final vehicleInfos = ['Renault Clio 2018', 'Peugeot 208 2020', 'Volkswagen Golf 2019', 'Toyota Corolla 2021', 'Ford Focus 2017'];
    
    final List<Map<String, dynamic>> messages = [];
    
    for (int i = 0; i < 20; i++) {
      final now = DateTime.now();
      final date = now.subtract(Duration(days: i ~/ 2, hours: i * 3));
      final status = i % 5 == 0 ? 'unread' : i % 5 == 1 ? 'pending' : i % 5 == 2 ? 'responded' : 'archived';
      
      messages.add({
        'id': 'MSG$i',
        'subject': subjects[i % subjects.length],
        'clientName': clientNames[i % clientNames.length],
        'clientId': 'C${i % 10 + 1}',
        'date': date,
        'status': status,
        'isRead': status != 'unread',
        'message': 'Bonjour l\'u00e9quipe KARHABTI,\n\nJe vous contacte au sujet de ${subjects[i % subjects.length].toLowerCase()}. ' + 
                 'J\'aimerais avoir plus d\'informations ou de l\'aide concernant ce problu00e8me.\n\n' + 
                 'Merci d\'avance pour votre ru00e9ponse.\n\nCordialement,\n${clientNames[i % clientNames.length]}',
        'vehicleInfo': vehicleInfos[i % vehicleInfos.length],
        'vehicleId': 'V${i % 5 + 1}',
        'response': status == 'responded' || status == 'archived' ? 
                   'Bonjour ${clientNames[i % clientNames.length]},\n\nMerci pour votre message. ' + 
                   'Nous avons bien reu00e7u votre demande concernant ${subjects[i % subjects.length].toLowerCase()}.\n\n' + 
                   'Notre u00e9quipe est u00e0 votre disposition pour toute information complu00e9mentaire.\n\n' + 
                   'Cordialement,\nL\'u00e9quipe KARHABTI' : null,
      });
    }
    
    setState(() {
      _messages = messages;
    });
  }
  
  List<Map<String, dynamic>> get filteredMessages {
    if (_selectedCategory == 'Tous') {
      return _messages;
    } else if (_selectedCategory == 'Non lus') {
      return _messages.where((msg) => msg['status'] == 'unread').toList();
    } else if (_selectedCategory == 'En attente') {
      return _messages.where((msg) => msg['status'] == 'pending').toList();
    } else if (_selectedCategory == 'Ru00e9pondus') {
      return _messages.where((msg) => msg['status'] == 'responded').toList();
    } else { // Archivu00e9s
      return _messages.where((msg) => msg['status'] == 'archived').toList();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildHeader(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildStatCards(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Row(
                children: [
                  // Panneau de navigation u00e0 gauche
                  SizedBox(
                    width: 300,
                    child: _buildMessagesList(),
                  ),
                  // Su00e9parateur vertical
                  Container(
                    width: 1,
                    color: AppTheme.lightGreyColor,
                  ),
                  // Du00e9tails du message u00e0 droite
                  Expanded(
                    child: _buildMessageDetails(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback & Messages',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Gu00e9rez les retours et messages des utilisateurs de l\'application KARHABTI',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
        ),
      ],
    );
  }
  
  Widget _buildStatCards() {
    final int totalMessages = _messages.length;
    final int unreadMessages = _messages.where((msg) => msg['status'] == 'unread').length;
    final int pendingMessages = _messages.where((msg) => msg['status'] == 'pending').length;
    final int respondedMessages = _messages.where((msg) => msg['status'] == 'responded').length;
    final int archivedMessages = _messages.where((msg) => msg['status'] == 'archived').length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total',
            value: totalMessages.toString(),
            icon: Icons.message,
            iconColor: AppTheme.primaryColor,
            onTap: () {
              setState(() {
                _selectedCategory = 'Tous';
                _selectedIndex = -1;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Non lus',
            value: unreadMessages.toString(),
            icon: Icons.mark_email_unread,
            iconColor: AppTheme.dangerColor,
            onTap: () {
              setState(() {
                _selectedCategory = 'Non lus';
                _selectedIndex = -1;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'En attente',
            value: pendingMessages.toString(),
            icon: Icons.pending_actions,
            iconColor: AppTheme.accentColor,
            onTap: () {
              setState(() {
                _selectedCategory = 'En attente';
                _selectedIndex = -1;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Ru00e9pondus',
            value: respondedMessages.toString(),
            icon: Icons.done_all,
            iconColor: AppTheme.successColor,
            onTap: () {
              setState(() {
                _selectedCategory = 'Ru00e9pondus';
                _selectedIndex = -1;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Archivu00e9s',
            value: archivedMessages.toString(),
            icon: Icons.archive,
            iconColor: AppTheme.greyColor,
            onTap: () {
              setState(() {
                _selectedCategory = 'Archivu00e9s';
                _selectedIndex = -1;
              });
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessagesList() {
    return Column(
      children: [
        // Barre de recherche et filtres
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.lightGreyColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtrer',
                itemBuilder: (context) => _categories
                    .map((category) => PopupMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedIndex = -1;
                  });
                },
              ),
            ],
          ),
        ),
        // Liste des messages
        Expanded(
          child: ListView.separated(
            itemCount: filteredMessages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final message = filteredMessages[index];
              final isSelected = index == _selectedIndex;
              final isUnread = message['status'] == 'unread';
              
              return ListTile(
                selected: isSelected,
                selectedTileColor: AppTheme.primaryColor.withOpacity(0.05),
                leading: CircleAvatar(
                  backgroundColor: isUnread ? AppTheme.primaryColor : AppTheme.greyColor.withOpacity(0.1),
                  radius: 18,
                  child: Text(
                    message['clientName'].toString().substring(0, 1),
                    style: TextStyle(
                      color: isUnread ? AppTheme.whiteColor : AppTheme.greyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  message['subject'],
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    color: isUnread ? AppTheme.darkColor : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${message['clientName']} u2022 ${_formatDate(message['date'])}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: _getStatusIcon(message['status']),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    // Marquer comme lu si nu00e9cessaire
                    if (message['status'] == 'unread') {
                      message['status'] = 'pending';
                      message['isRead'] = true;
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageDetails() {
    if (_selectedIndex == -1 || filteredMessages.isEmpty) {
      return const Center(
        child: Text('Su00e9lectionnez un message pour voir les du00e9tails'),
      );
    }
    
    final message = filteredMessages[_selectedIndex];
    
    return Column(
      children: [
        // Entu00eate du message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.lightGreyColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['subject'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'De: ${message['clientName']}',
                        style: const TextStyle(color: AppTheme.greyColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Vu00e9hicule: ${message['vehicleInfo']}',
                        style: const TextStyle(color: AppTheme.greyColor),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (message['status'] != 'archived')
                    IconButton(
                      icon: const Icon(Icons.archive),
                      tooltip: 'Archiver',
                      onPressed: () {
                        setState(() {
                          message['status'] = 'archived';
                        });
                        _showSnackBar('Message archivu00e9');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Supprimer',
                    onPressed: () => _confirmDeleteMessage(),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Corps du message
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message original
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            child: Text(message['clientName'].toString().substring(0, 1)),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['clientName'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _formatDate(message['date'], showTime: true),
                                style: const TextStyle(fontSize: 12, color: AppTheme.greyColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(message['message']),
                    ],
                  ),
                ),
                
                // Ru00e9ponse si disponible
                if (message['response'] != null) ...[  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primaryColor,
                              child: Icon(Icons.support_agent, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'L\'u00e9quipe KARHABTI',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Ru00e9pondu ${_formatDate(message['date'].add(const Duration(hours: 2)), showTime: true)}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.greyColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(message['response']),
                      ],
                    ),
                  ),
                ],
                
                // Zone de ru00e9ponse si le message n'est pas encore ru00e9pondu
                if (message['status'] != 'responded' && message['status'] != 'archived') ...[  
                  const SizedBox(height: 24),
                  const Text(
                    'Ru00e9pondre',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Votre ru00e9ponse...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _sendResponse(),
                        child: const Text('Envoyer'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'unread':
        return Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.dangerColor,
          ),
        );
      case 'pending':
        return const Icon(Icons.watch_later, color: AppTheme.accentColor, size: 18);
      case 'responded':
        return const Icon(Icons.done_all, color: AppTheme.successColor, size: 18);
      case 'archived':
        return const Icon(Icons.archive, color: AppTheme.greyColor, size: 18);
      default:
        return const SizedBox.shrink();
    }
  }
  
  String _formatDate(DateTime date, {bool showTime = false}) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours} h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      if (showTime) {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
  
  void _sendResponse() {
    if (_selectedIndex >= 0) {
      setState(() {
        filteredMessages[_selectedIndex]['status'] = 'responded';
        filteredMessages[_selectedIndex]['response'] = 'Bonjour ${filteredMessages[_selectedIndex]['clientName']},\n\nMerci pour votre message. ' + 
               'Nous avons bien reu00e7u votre demande concernant ${filteredMessages[_selectedIndex]['subject'].toLowerCase()}.\n\n' + 
               'Notre u00e9quipe est u00e0 votre disposition pour toute information complu00e9mentaire.\n\n' + 
               'Cordialement,\nL\'u00e9quipe KARHABTI';
      });
      _showSnackBar('Ru00e9ponse envoyu00e9e avec succu00e8s');
    }
  }
  
  void _confirmDeleteMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le message'),
          content: const Text('u00cates-vous su00fbr de vouloir supprimer ce message ? Cette action est irru00e9versible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  if (_selectedIndex >= 0) {
                    final messageId = filteredMessages[_selectedIndex]['id'];
                    _messages.removeWhere((msg) => msg['id'] == messageId);
                    _selectedIndex = -1;
                  }
                });
                _showSnackBar('Message supprimu00e9');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
