import 'package:flutter/material.dart';

// ══════════════════════════════════════════
//  MESSAGE MODEL
// ══════════════════════════════════════════
enum MessageType { text, voice, image, sticker, scheduledLetter, system }

class ChatMessage {
  final String id;
  final String content;
  final bool isMe;
  final DateTime sentAt;
  final MessageType type;
  final List<String> reactions;
  // For scheduled letters
  final DateTime? openAt;
  bool isOpened;
  final String? letterTitle;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.sentAt,
    this.type = MessageType.text,
    this.reactions = const [],
    this.openAt,
    this.isOpened = false,
    this.letterTitle,
  });

  bool get isLocked =>
      type == MessageType.scheduledLetter &&
      !isOpened &&
      openAt != null &&
      DateTime.now().isBefore(openAt!);

  ChatMessage copyWith({bool? isOpened}) => ChatMessage(
        id: id,
        content: content,
        isMe: isMe,
        sentAt: sentAt,
        type: type,
        reactions: reactions,
        openAt: openAt,
        isOpened: isOpened ?? this.isOpened,
        letterTitle: letterTitle,
      );
}

// ══════════════════════════════════════════
//  MOOD MODEL
// ══════════════════════════════════════════
class MoodEntry {
  final String emoji;
  final String label;
  final String message;
  final DateTime at;

  const MoodEntry({
    required this.emoji,
    required this.label,
    this.message = '',
    required this.at,
  });
}

const List<Map<String, String>> moodOptions = [
  {'e': '😊', 'l': 'سعيد'},
  {'e': '😍', 'l': 'محب'},
  {'e': '😴', 'l': 'متعب'},
  {'e': '😔', 'l': 'حزين'},
  {'e': '😂', 'l': 'ضاحك'},
  {'e': '🤩', 'l': 'متحمس'},
  {'e': '🥺', 'l': 'محتاج حب'},
  {'e': '🥰', 'l': 'ممتنن'},
  {'e': '😤', 'l': 'زعلان'},
  {'e': '😰', 'l': 'قلقان'},
];

// ══════════════════════════════════════════
//  IDEA MODEL
// ══════════════════════════════════════════
enum IdeaCategory { travel, home, date, dream, other }

extension IdeaCategoryExt on IdeaCategory {
  String get nameAr {
    switch (this) {
      case IdeaCategory.travel: return 'سفر';
      case IdeaCategory.home: return 'البيت';
      case IdeaCategory.date: return 'لقاء رومانسي';
      case IdeaCategory.dream: return 'حلم مشترك';
      case IdeaCategory.other: return 'أخرى';
    }
  }
  String get emoji {
    switch (this) {
      case IdeaCategory.travel: return '✈️';
      case IdeaCategory.home: return '🏠';
      case IdeaCategory.date: return '💕';
      case IdeaCategory.dream: return '🌙';
      case IdeaCategory.other: return '💛';
    }
  }
  Color get color {
    switch (this) {
      case IdeaCategory.travel: return const Color(0xFF4FC3F7);
      case IdeaCategory.home: return const Color(0xFF81C784);
      case IdeaCategory.date: return const Color(0xFFF48FB1);
      case IdeaCategory.dream: return const Color(0xFFCE93D8);
      case IdeaCategory.other: return const Color(0xFFC9A84C);
    }
  }
}

class Idea {
  final String id;
  final String title;
  final String description;
  final IdeaCategory category;
  final String addedBy;
  int likes;
  bool liked;
  final DateTime createdAt;

  Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.addedBy,
    this.likes = 0,
    this.liked = false,
    required this.createdAt,
  });
}

// ══════════════════════════════════════════
//  TODO MODEL
// ══════════════════════════════════════════
class TodoItem {
  final String id;
  final String title;
  bool isDone;
  final String assignedTo;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.assignedTo,
  });
}

// ══════════════════════════════════════════
//  DISCUSSION QUESTION
// ══════════════════════════════════════════
enum DiscMood { romantic, fun, deep, movie }

extension DiscMoodExt on DiscMood {
  String get nameAr {
    switch (this) {
      case DiscMood.romantic: return 'رومانسي';
      case DiscMood.fun: return 'مرح';
      case DiscMood.deep: return 'عميق';
      case DiscMood.movie: return 'عن الفيلم';
    }
  }
  String get emoji {
    switch (this) {
      case DiscMood.romantic: return '💕';
      case DiscMood.fun: return '😂';
      case DiscMood.deep: return '🌙';
      case DiscMood.movie: return '🎬';
    }
  }
}

const Map<DiscMood, List<String>> discQuestions = {
  DiscMood.romantic: [
    'لو قدرتوا تسافرون لأي مكان في العالم الليلة، وين تختارون؟ 🌍✈️',
    'ما هو أجمل لحظة عشتموها معاً حتى الآن؟ 🌹',
    'ما هو الشي اللي تحبه فيّ أكثر شي؟ 💛',
    'وصف الحياة المثالية اللي تتخيلها لنا بعد ٥ سنوات 🌙',
    'لو كتبت لي رسالة بعد ١٠ سنوات، إيش تكتب؟ 💌',
    'إيش يجيك على بالك لما تسمع اسمي؟ ✨',
  ],
  DiscMood.fun: [
    'لو كنت حيوان إيش تكون؟ ولماذا؟ 🦁',
    'أكثر شي يضحكك مني إيش؟ 😂',
    'كيف تصف يومنا في ٣ إيموجي فقط؟',
    'من فيكم الأكثر فوضوية؟ 🙈',
    'لو نلعب لعبة تحدي الآن إيش تختار؟ 🎯',
    'أكثر شي محرج حدث لك أمامي؟ 😳',
  ],
  DiscMood.deep: [
    'إيش أكثر شي تغيّر فيك منذ كنّا مع بعض؟ 🌱',
    'ما هو حلمك الكبير اللي لسا ما حققته؟ 🌟',
    'ما هو الشي اللي يخوفك في المستقبل؟ 🤍',
    'ما الدرس الأهم اللي علّمتك إياه الحياة؟ 📖',
    'لو قدرت تغير شي واحد في ماضيك، إيش تغير؟ ⏳',
    'متى آخر مرة شعرت بسعادة حقيقية؟ 💙',
  ],
  DiscMood.movie: [
    'أكثر مشهد في الفيلم أثّر فيك، ليش؟ 🎬',
    'لو أنتم الشخصيتين الرئيسيتين، مين منكم مين؟ 😄',
    'هل كنت تتوقع هالنهاية؟ 🤔',
    'الفيلم يذكرك بأي لحظة من حياتكم؟ 🌙',
    'هل تنصح أحد بمشاهدته؟ ولماذا؟ ⭐',
    'إيش أكثر جملة في الفيلم أعجبتك؟ 💬',
  ],
};

// ══════════════════════════════════════════
//  GAME MODEL
// ══════════════════════════════════════════
enum GameCategory { romantic, fun, mind, adventure }

extension GameCategoryExt on GameCategory {
  String get nameAr {
    switch (this) {
      case GameCategory.romantic: return 'رومانسي';
      case GameCategory.fun: return 'مرح';
      case GameCategory.mind: return 'تحدٍّ';
      case GameCategory.adventure: return 'مغامرة';
    }
  }
  String get emoji {
    switch (this) {
      case GameCategory.romantic: return '💕';
      case GameCategory.fun: return '😂';
      case GameCategory.mind: return '🧠';
      case GameCategory.adventure: return '🌟';
    }
  }
  Color get color {
    switch (this) {
      case GameCategory.romantic: return const Color(0xFFF48FB1);
      case GameCategory.fun: return const Color(0xFFFFB347);
      case GameCategory.mind: return const Color(0xFFCE93D8);
      case GameCategory.adventure: return const Color(0xFF4FC3F7);
    }
  }
}

class GameModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final GameCategory category;
  final List<String> steps;

  const GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.steps,
  });
}

const List<GameModel> allGames = [
  GameModel(id:'g1',title:'رسالة من القلب',description:'كل واحد يكتب رسالة قصيرة للآخر في ٣٠ ثانية ثم يقرأها',icon:'💌',category:GameCategory.romantic,steps:['كل واحد يكتب رسالة في ٣٠ ثانية','لا تريا ما يكتبه الآخر','تبادلا الرسائل في نفس الوقت','اقرأ رسالة شريكك بصوت عالٍ']),
  GameModel(id:'g2',title:'من أنا؟',description:'فكّر بشخصية والآخر يسأل أسئلة نعم/لا ليخمن',icon:'🤔',category:GameCategory.fun,steps:['أحدكم يفكر بشخصية مشهورة','الآخر يسأل أسئلة بإجابة نعم أو لا','يملك ٢٠ سؤالاً فقط للتخمين','إذا خمّن صح ينتقل الدور']),
  GameModel(id:'g3',title:'تحدي الكلمات',description:'قل كلمة والآخر يكمل بكلمة تبدأ بآخر حرف في ٥ ثوانٍ',icon:'🧩',category:GameCategory.mind,steps:['أحدكم يقول كلمة','الآخر لديه ٥ ثوانٍ يقول كلمة تبدأ بآخر حرف','من يفشل يخسر نقطة','يلعبان ١٠ جولات']),
  GameModel(id:'g4',title:'الحقيقة أو التحدي',description:'بديل رومانسي: سؤال صريح أو تحدٍّ لطيف',icon:'🎯',category:GameCategory.romantic,steps:['أحدكم يختار: حقيقة أو تحدٍّ','إذا حقيقة: أجب بصدق تام','إذا تحدٍّ: نفّذ ما يطلبه الشريك','تناوبا الأدوار كل جولة']),
  GameModel(id:'g5',title:'الممثل الصامت',description:'أحدهم يمثّل فيلماً بدون كلام والآخر يخمن',icon:'😂',category:GameCategory.fun,steps:['أحدكم يفكر بفيلم أو مسلسل','يمثّله بالحركة فقط بدون كلام','الآخر لديه دقيقة للتخمين','من يخمن أكثر يفوز']),
  GameModel(id:'g6',title:'من يعرف الآخر أكثر؟',description:'أسئلة عن عادات وتفضيلات الشريك لمن يحصل على أعلى نقاط',icon:'📚',category:GameCategory.mind,steps:['كل واحد يكتب ٥ أسئلة عن نفسه','تبادلا الأسئلة وأجيبا','كل إجابة صحيحة = نقطة','من يحصل على أكثر نقاط يفوز']),
  GameModel(id:'g7',title:'مغامرة التخطيط',description:'في ١٠ دقائق خططوا معاً لرحلة مثالية بميزانية خيالية',icon:'🗺️',category:GameCategory.adventure,steps:['الميزانية: مليون دولار وهمي','عندكم ١٠ دقائق فقط','خططوا: الوجهة، الفندق، الأنشطة','عرضوا الخطة على بعض']),
  GameModel(id:'g8',title:'قائمة المحبة',description:'كل واحد يكتب ٥ أشياء يحبها في الآخر ثم يتبادلانها',icon:'⭐',category:GameCategory.romantic,steps:['كل واحد يكتب ٥ أشياء يحبها في الآخر','لا تريا ما يكتبه الآخر','تبادلا القوائم','اقرأ قائمة شريكك بصوت عالٍ مع ابتسامة']),
  GameModel(id:'g9',title:'ارسم بعضكم',description:'كل واحد يرسم الآخر في ٦٠ ثانية ثم يقارنان النتيجة',icon:'🎨',category:GameCategory.fun,steps:['كل واحد يأخذ ورقة وقلم','عندكم ٦٠ ثانية فقط','ارسم شريكك من الذاكرة','قارنا الرسومات وضحكا معاً']),
  GameModel(id:'g10',title:'تحدي الأرقام',description:'فكّر برقم بين ١-١٠٠ والآخر لديه ٧ محاولات ليخمن',icon:'🔢',category:GameCategory.mind,steps:['أحدكم يفكر برقم بين ١ و ١٠٠','الآخر يخمن الرقم','قل "أكبر" أو "أصغر" بعد كل تخمين','يملك ٧ محاولات فقط']),
  GameModel(id:'g11',title:'أحلامنا المشتركة',description:'كل واحد يذكر ٣ أحلام للمستقبل ونرى كم منها مشترك',icon:'🌙',category:GameCategory.romantic,steps:['كل واحد يكتب ٣ أحلام للمستقبل','اكتبوها بدون أن يرى الآخر','تبادلا القوائم','احتفلوا بكل حلم مشترك']),
  GameModel(id:'g12',title:'القصة التعاونية',description:'كل واحد يضيف جملة لقصة مشتركة إلى أين تصل؟',icon:'👻',category:GameCategory.fun,steps:['أحدكم يبدأ قصة بجملة واحدة','الآخر يكمل بجملة واحدة فقط','تناوبا حتى تنتهي القصة','القصة الأطول والأغرب تفوز']),
  GameModel(id:'g13',title:'خمّن الأغنية',description:'أحدهم يكتب كلمة واحدة من أغنية والآخر يخمنها',icon:'🎵',category:GameCategory.mind,steps:['أحدكم يفكر بأغنية','يكتب كلمة واحدة منها فقط','الآخر يحاول التخمين','إذا فشل يكشف كلمة ثانية']),
  GameModel(id:'g14',title:'ذكرياتنا الحلوة',description:'كل واحد يصف ذكرى مشتركة دون اسمها والآخر يخمن',icon:'💞',category:GameCategory.romantic,steps:['كل واحد يفكر بذكرى مشتركة','يصفها دون ذكر المكان أو الوقت','الآخر يخمن أي ذكرى هي','من يخمن أكثر يفوز']),
  GameModel(id:'g15',title:'بطاقة التحدي اليومي',description:'اقترحوا تحدياً صغيراً تفعلانه معاً قبل نهاية اليوم',icon:'🌟',category:GameCategory.adventure,steps:['كل واحد يقترح تحدياً يومياً','اختارا تحدياً واحداً معاً','نفّذاه قبل نهاية اليوم','التقطا صورة لتوثيق التحدي']),
  GameModel(id:'g16',title:'خمّن التعبير',description:'أحدهم يصف مشاعره بإيموجي فقط والآخر يحكي ما يفهم',icon:'🤣',category:GameCategory.fun,steps:['أحدكم يختار ٣ إيموجي تعبّر عن يومه','الآخر يشرح ما يفهمه','الأقرب للحقيقة يفوز','تناوبا الأدوار']),
  GameModel(id:'g17',title:'اختبار الشريك',description:'١٠ أسئلة سريعة عن الآخر من يجيب أكثر؟',icon:'🧠',category:GameCategory.mind,steps:['أحدكم يسأل سؤالاً عن نفسه','الآخر يجيب بسرعة','كل إجابة صحيحة نقطة','من يصل لـ ١٠ نقاط أولاً يفوز']),
  GameModel(id:'g18',title:'مفاجأة اليوم',description:'كل واحد يخطط لمفاجأة صغيرة للآخر خلال ٢٤ ساعة',icon:'🎁',category:GameCategory.romantic,steps:['كل واحد يفكر بمفاجأة صغيرة','لا تخبر الآخر ما ستفعله','نفّذ المفاجأة خلال ٢٤ ساعة','شاركوا ردود أفعالكم']),
  GameModel(id:'g19',title:'تحدي المعرفة',description:'اختبار سريع: ثقافة، جغرافيا، أفلام من الأذكى؟',icon:'🏆',category:GameCategory.adventure,steps:['كل واحد يحضر ٥ أسئلة ثقافية','تناوبا في السؤال والجواب','كل إجابة صحيحة نقطة','اللعبة تنتهي عند ١٥ نقطة']),
  GameModel(id:'g20',title:'صناعة قائمة الدلال',description:'كل واحد يكتب ٥ أشياء يريد أن يفعلها الشريك له',icon:'💆',category:GameCategory.romantic,steps:['كل واحد يكتب ٥ طلبات دلال','الطلبات تكون بسيطة وممكنة','تبادلا القوائم','حاولا تنفيذ طلب واحد اليوم']),
];
