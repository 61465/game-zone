import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

// ══════════════════════════════════════════
//  APP PROVIDER  (Provider pattern)
// ══════════════════════════════════════════
class AppProvider extends ChangeNotifier {

  // ── Theme ──
  AppThemeId _themeId = AppThemeId.golden;
  bool _isFightMode = false;

  AppThemeId get themeId => _themeId;
  bool get isFightMode => _isFightMode;
  AppThemeData get currentTheme =>
      _isFightMode ? fightTheme : appThemes[_themeId]!;

  void setTheme(AppThemeId id) {
    _themeId = id;
    if (_isFightMode) _isFightMode = false;
    notifyListeners();
  }

  // ── Low-net mode ──
  bool _lowNet = false;
  bool get lowNet => _lowNet;
  void toggleLowNet() { _lowNet = !_lowNet; notifyListeners(); }

  // ── Partners ──
  String myName = 'أنت';
  String myInitial = 'أ';
  String partnerName = 'سارة 🌹';
  String partnerInitial = 'س';

  // ── Mood ──
  MoodEntry myMood = MoodEntry(emoji:'😊', label:'سعيد', message:'كلو بخير 💛', at: DateTime.now());
  MoodEntry herMood = MoodEntry(emoji:'😴', label:'متعبة', message:'تعبانة شوي', at: DateTime.now());

  List<MoodEntry> moodHistory = [];

  void setMyMood(String emoji, String label, String message) {
    myMood = MoodEntry(emoji: emoji, label: label, message: message, at: DateTime.now());
    moodHistory.insert(0, myMood);
    notifyListeners();
  }

  String get moodCompatEmoji {
    if (_isFightMode) return '😤';
    const happyEmojis = ['😊','😍','😂','🤩','🥰'];
    final myH = happyEmojis.contains(myMood.emoji);
    final herH = happyEmojis.contains(herMood.emoji);
    if (myH && herH) return '💞';
    if (!myH && !herH) return '🤍';
    return '💛';
  }

  String get moodCompatLabel {
    if (_isFightMode) return 'خذوا وقتاً';
    const happyEmojis = ['😊','😍','😂','🤩','🥰'];
    final myH = happyEmojis.contains(myMood.emoji);
    final herH = happyEmojis.contains(herMood.emoji);
    if (myH && herH) return 'منسجمان';
    if (!myH && !herH) return 'تحتاجان دعماً';
    return 'ادعم شريكك';
  }

  // ── Fight mode ──
  String fightWho = 'me'; // 'me' | 'her' | 'both'
  String fightReason = '';

  void activateFightMode({String who='me', String reason=''}) {
    _isFightMode = true;
    fightWho = who;
    fightReason = reason;
    addSystemMessage('😤 وضع المشاجرة مفعّل. خذوا وقتكم للتهدئة 💙');
    notifyListeners();
  }

  void makePeace() {
    _isFightMode = false;
    fightWho = '';
    fightReason = '';
    addSystemMessage('🕊️ تم الصلح! عودة للحب ❤️');
    notifyListeners();
  }

  // ── Messages ──
  final List<ChatMessage> messages = [
    ChatMessage(id:'m1', content:'صباح النور يا قلبي 🌅', isMe:false, sentAt:DateTime.now().subtract(const Duration(hours:2)), type:MessageType.text),
    ChatMessage(id:'m2', content:'صباح الورد والياسمين 💛 وانتي ما معي ما أشوف الفيلم', isMe:true, sentAt:DateTime.now().subtract(const Duration(hours:2)), type:MessageType.text, reactions:['❤️']),
    ChatMessage(id:'m3', content:'بحبك يا روحي 🌹✨', isMe:false, sentAt:DateTime.now().subtract(const Duration(hours:1)), type:MessageType.text),
    ChatMessage(id:'m4', content:'يا سارة، أكتب لك هذه الرسالة وأنا أفكر فيكِ... أنتِ أجمل شيء في حياتي 🌹', isMe:true, sentAt:DateTime.now().subtract(const Duration(minutes:30)), type:MessageType.scheduledLetter, letterTitle:'رسالة المساء 💌', openAt:DateTime.now().add(const Duration(hours:2)), isOpened:false),
  ];

  void sendMessage(String content, {MessageType type = MessageType.text}) {
    messages.add(ChatMessage(
      id: _uuid.v4(),
      content: content,
      isMe: true,
      sentAt: DateTime.now(),
      type: type,
    ));
    notifyListeners();
    // Simulate partner reply
    Future.delayed(const Duration(milliseconds: 1400), () {
      const replies = ['بحبك أكثر 💛', 'وانا كمان 😊❤️', 'ما أقدر استنى 🥰', 'أنت عالمي 💕', '🥰💕'];
      messages.add(ChatMessage(
        id: _uuid.v4(),
        content: replies[DateTime.now().millisecond % replies.length],
        isMe: false,
        sentAt: DateTime.now(),
        type: MessageType.text,
      ));
      notifyListeners();
    });
  }

  void addSystemMessage(String content) {
    messages.add(ChatMessage(
      id: _uuid.v4(),
      content: content,
      isMe: true,
      sentAt: DateTime.now(),
      type: MessageType.system,
    ));
    notifyListeners();
  }

  void sendScheduledLetter(String title, String content, DateTime openAt) {
    messages.add(ChatMessage(
      id: _uuid.v4(),
      content: content,
      isMe: true,
      sentAt: DateTime.now(),
      type: MessageType.scheduledLetter,
      letterTitle: title.isEmpty ? 'رسالة مؤجلة 💌' : title,
      openAt: openAt,
      isOpened: false,
    ));
    notifyListeners();
  }

  void openLetter(String id) {
    final i = messages.indexWhere((m) => m.id == id);
    if (i != -1) {
      messages[i] = messages[i].copyWith(isOpened: true);
      notifyListeners();
    }
  }

  void addReaction(String msgId, String emoji) {
    final i = messages.indexWhere((m) => m.id == msgId);
    if (i != -1) {
      final msg = messages[i];
      final reactions = List<String>.from(msg.reactions);
      if (reactions.contains(emoji)) reactions.remove(emoji);
      else reactions.add(emoji);
      messages[i] = ChatMessage(
        id: msg.id, content: msg.content, isMe: msg.isMe,
        sentAt: msg.sentAt, type: msg.type, reactions: reactions,
        openAt: msg.openAt, isOpened: msg.isOpened, letterTitle: msg.letterTitle,
      );
      notifyListeners();
    }
  }

  // ── Ideas ──
  final List<Idea> ideas = [
    Idea(id:'i1', title:'رحلة إلى كبادوكيا 🎈', description:'نطير بالبالون في السماء ونبقى في فندق كهف رومانسي', category:IdeaCategory.travel, addedBy:'سارة', likes:3, liked:false, createdAt:DateTime.now()),
    Idea(id:'i2', title:'غرفة جلوس جديدة 🛋️', description:'تغيير ديكور الصالة بألوان دافئة وإضاءة ناعمة', category:IdeaCategory.home, addedBy:'أنت', likes:2, liked:true, createdAt:DateTime.now()),
    Idea(id:'i3', title:'عشاء على السطح 🌙', description:'نجهز طاولة رومانسية على سطح البيت تحت النجوم', category:IdeaCategory.date, addedBy:'أنت', likes:5, liked:false, createdAt:DateTime.now()),
    Idea(id:'i4', title:'تعلم الطبخ الإيطالي 🍝', description:'نسجل في كورس طبخ مع بعض كل أسبوع', category:IdeaCategory.dream, addedBy:'سارة', likes:1, liked:false, createdAt:DateTime.now()),
    Idea(id:'i5', title:'كتاب ذكرياتنا ✍️', description:'نكتب معاً كتاباً خاصاً بنا فيه كل اللحظات الجميلة', category:IdeaCategory.other, addedBy:'سارة', likes:4, liked:true, createdAt:DateTime.now()),
  ];

  IdeaCategory? ideaFilter;

  List<Idea> get filteredIdeas =>
      ideaFilter == null ? ideas : ideas.where((i) => i.category == ideaFilter).toList();

  void setIdeaFilter(IdeaCategory? cat) { ideaFilter = cat; notifyListeners(); }

  void addIdea(String title, String desc, IdeaCategory cat) {
    ideas.insert(0, Idea(id: _uuid.v4(), title: title, description: desc, category: cat, addedBy: 'أنت', createdAt: DateTime.now()));
    notifyListeners();
  }

  void toggleIdeaLike(String id) {
    final idea = ideas.firstWhere((i) => i.id == id);
    idea.liked = !idea.liked;
    idea.likes += idea.liked ? 1 : -1;
    notifyListeners();
  }

  // ── Todos ──
  final List<TodoItem> todos = [
    TodoItem(id:'t1', title:'حليب وبيض', isDone:true, assignedTo:'سارة'),
    TodoItem(id:'t2', title:'خبز طازج', isDone:false, assignedTo:'أنت'),
    TodoItem(id:'t3', title:'فواكه للأسبوع', isDone:false, assignedTo:'أنت'),
    TodoItem(id:'t4', title:'احجاز مطعم الجمعة', isDone:true, assignedTo:'سارة'),
    TodoItem(id:'t5', title:'تجديد اشتراك نتفليكس', isDone:false, assignedTo:'أنت'),
  ];

  void toggleTodo(String id) {
    final t = todos.firstWhere((x) => x.id == id);
    t.isDone = !t.isDone;
    notifyListeners();
  }

  void addTodo(String title) {
    todos.add(TodoItem(id: _uuid.v4(), title: title, assignedTo: 'أنت'));
    notifyListeners();
  }

  // ── Discussion ──
  DiscMood discMood = DiscMood.romantic;
  int discIndex = 0;

  String get currentQuestion => discQuestions[discMood]![discIndex % discQuestions[discMood]!.length];

  void nextQuestion() {
    discIndex++;
    notifyListeners();
  }

  void setDiscMood(DiscMood m) {
    discMood = m;
    discIndex = 0;
    notifyListeners();
  }

  // ── Active game ──
  GameModel? activeGame;
  int myScore = 0;
  int herScore = 0;
  int gameStep = 0;

  void startGame(GameModel game) {
    activeGame = game;
    myScore = 0;
    herScore = 0;
    gameStep = 0;
    notifyListeners();
  }

  void closeGame() {
    activeGame = null;
    notifyListeners();
  }

  void addMyScore() { myScore++; notifyListeners(); }
  void addHerScore() { herScore++; notifyListeners(); }
  void nextGameStep() { gameStep++; notifyListeners(); }
}
