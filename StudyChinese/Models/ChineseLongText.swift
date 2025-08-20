//
//  ChineseLongText.swift
//  StudyChinese
//
//  Created by AI Assistant on 1/21/25.
//

import Foundation

// 中国語長文データモデル
struct ChineseLongText: Identifiable, Hashable {
    let id = UUID()
    let title: String                    // 長文のタイトル
    let category: LongTextCategory       // カテゴリ（日常会話、ビジネス、文学など）
    let level: DifficultyLevel          // 難易度レベル
    let chineseText: String             // 中国語本文
    let pinyinText: String              // 拼音（ピンイン）
    let japaneseTranslation: String     // 日本語翻訳
    let audioFileName: String?          // 音声ファイル名
    let keyWords: [KeyWord]             // 重要単語
    let grammarPoints: [GrammarPoint]   // 文法ポイント
    let exerciseQuestions: [ExerciseQuestion] // 練習問題
    
    // 重要単語構造体
    struct KeyWord: Identifiable, Hashable {
        let id = UUID()
        let word: String
        let pinyin: String
        let meaning: String
        let contextSentence: String     // 文脈での例文
    }
    
    // 文法ポイント構造体
    struct GrammarPoint: Identifiable, Hashable {
        let id = UUID()
        let point: String
        let explanation: String
        let examples: [String]
    }
    
    // 練習問題構造体
    struct ExerciseQuestion: Identifiable, Hashable {
        let id = UUID()
        let question: String
        let options: [String]?          // 選択肢（選択問題の場合）
        let correctAnswer: String
        let explanation: String
        let type: QuestionType
    }
    
    // 質問タイプ
    enum QuestionType: String, CaseIterable {
        case multipleChoice = "multiple_choice"    // 選択問題
        case fillInBlank = "fill_in_blank"         // 穴埋め問題
        case translation = "translation"           // 翻訳問題
        case comprehension = "comprehension"       // 読解問題
    }
}

// 長文カテゴリ
enum LongTextCategory: String, CaseIterable {
    case dailyConversation = "daily_conversation"
    case business = "business"
    case culture = "culture"
    case history = "history"
    case literature = "literature"
    case science = "science"
    case travel = "travel"
    case food = "food"
    case education = "education"
    case health = "health"
    
    var displayName: String {
        switch self {
        case .dailyConversation: return "日常会話"
        case .business: return "ビジネス"
        case .culture: return "文化"
        case .history: return "歴史"
        case .literature: return "文学"
        case .science: return "科学"
        case .travel: return "旅行"
        case .food: return "料理"
        case .education: return "教育"
        case .health: return "健康"
        }
    }
    
    var icon: String {
        switch self {
        case .dailyConversation: return "message.circle"
        case .business: return "briefcase"
        case .culture: return "globe.asia.australia"
        case .history: return "clock.arrow.circlepath"
        case .literature: return "book.pages"
        case .science: return "atom"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .education: return "graduationcap"
        case .health: return "heart.text.square"
        }
    }
}

// 難易度レベル
enum DifficultyLevel: String, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner: return "初級"
        case .intermediate: return "中級"
        case .advanced: return "上級"
        case .expert: return "超級"
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
    
    var order: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .expert: return 4
        }
    }
}

// 長文データマネージャー
class ChineseLongTextData: ObservableObject {
    @Published var longTexts: [ChineseLongText] = []
    @Published var isLoading = false
    
    init() {
        loadSampleData()
    }
    
    // サンプルデータをロード
    private func loadSampleData() {
        longTexts = [
            createSampleText1(),
            createSampleText2(),
            createSampleText3(),
            createSampleText4(),
            createSampleText5(),
            createSampleText6(),
            createSampleText7(),
            createSampleText8(),
            createSampleText9(),
            createSampleText10()
        ]
    }
    
    // カテゴリ別でフィルタリング
    func texts(for category: LongTextCategory) -> [ChineseLongText] {
        return longTexts.filter { $0.category == category }
    }
    
    // 難易度別でフィルタリング
    func texts(for level: DifficultyLevel) -> [ChineseLongText] {
        return longTexts.filter { $0.level == level }
    }
    
    // 特定のカテゴリと難易度でフィルタリング
    func texts(for category: LongTextCategory, level: DifficultyLevel) -> [ChineseLongText] {
        return longTexts.filter { $0.category == category && $0.level == level }
    }
}

// MARK: - Sample Data
extension ChineseLongTextData {
    private func createSampleText1() -> ChineseLongText {
        return ChineseLongText(
            title: "自己紹介",
            category: .dailyConversation,
            level: .beginner,
            chineseText: "大家好，我叫李明。我今年二十五岁，来自北京。我是一名大学生，在北京大学学习中文。我的爱好是看书和听音乐。我很喜欢中国文化，特别是中国的历史和传统艺术。希望能和大家成为好朋友。",
            pinyinText: "Dà jiā hǎo, wǒ jiào Lǐ Míng. Wǒ jīn nián èr shí wǔ suì, lái zì Běi jīng. Wǒ shì yī míng dà xué shēng, zài Běi jīng Dà xué xué xí zhōng wén. Wǒ de ài hào shì kàn shū hé tīng yīn yuè. Wǒ hěn xǐ huan Zhōng guó wén huà, tè bié shì Zhōng guó de lì shǐ hé chuán tǒng yì shù. Xī wàng néng hé dà jiā chéng wéi hǎo péng yǒu.",
            japaneseTranslation: "皆さん、こんにちは。私は李明と申します。今年25歳で、北京出身です。私は大学生で、北京大学で中国語を学んでいます。趣味は読書と音楽鑑賞です。中国文化がとても好きで、特に中国の歴史と伝統芸術に興味があります。皆さんと良い友達になれることを願っています。",
            audioFileName: "long_text_intro.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "自己紹介", pinyin: "zìjǐ jièshào", meaning: "自己紹介", contextSentence: "我来做一个自己紹介"),
                ChineseLongText.KeyWord(word: "大学生", pinyin: "dàxuéshēng", meaning: "大学生", contextSentence: "我是一名大学生"),
                ChineseLongText.KeyWord(word: "爱好", pinyin: "àihào", meaning: "趣味", contextSentence: "我的爱好是看书"),
                ChineseLongText.KeyWord(word: "文化", pinyin: "wénhuà", meaning: "文化", contextSentence: "我很喜欢中国文化"),
                ChineseLongText.KeyWord(word: "传统", pinyin: "chuántǒng", meaning: "伝統", contextSentence: "中国的传统艺术")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "年齢の表現",
                    explanation: "「今年 + 数字 + 岁」で年齢を表現します",
                    examples: ["我今年二十五岁", "他今年三十岁", "她今年十八岁"]
                ),
                ChineseLongText.GrammarPoint(
                    point: "出身の表現",
                    explanation: "「来自 + 地名」で出身地を表現します",
                    examples: ["我来自北京", "他来自上海", "她来自日本"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "李明は何歳ですか？",
                    options: ["23歳", "25歳", "27歳", "30歳"],
                    correctAnswer: "25歳",
                    explanation: "「我今年二十五岁」から25歳であることがわかります。",
                    type: .multipleChoice
                ),
                ChineseLongText.ExerciseQuestion(
                    question: "李明の趣味は何ですか？",
                    options: nil,
                    correctAnswer: "読書と音楽鑑賞",
                    explanation: "「我的爱好是看书和听音乐」から読書と音楽鑑賞が趣味であることがわかります。",
                    type: .comprehension
                )
            ]
        )
    }
    
    private func createSampleText2() -> ChineseLongText {
        return ChineseLongText(
            title: "中国の伝統祭り",
            category: .culture,
            level: .intermediate,
            chineseText: "春节是中国最重要的传统节日，也叫做中国新年。每年农历正月初一是春节的第一天。在这个特殊的日子里，全家人会聚在一起吃年夜饭，放烟花，贴春联。孩子们会收到长辈给的红包。春节期间，人们会相互拜年，说恭喜发财、新年快乐等祝福的话。这个节日不仅是家庭团聚的时间，也是继承和发扬中华文化的重要时刻。",
            pinyinText: "Chūn jié shì Zhōng guó zuì zhòng yào de chuán tǒng jié rì, yě jiào zuò Zhōng guó xīn nián. Měi nián nóng lì zhēng yuè chū yī shì chūn jié de dì yī tiān. Zài zhè ge tè shū de rì zi lǐ, quán jiā rén huì jù zài yī qǐ chī nián yè fàn, fàng yān huā, tiē chūn lián. Hái zi men huì shōu dào zhǎng bèi gěi de hóng bāo. Chūn jié qī jiān, rén men huì xiāng hù bài nián, shuō 'gōng xǐ fā cái', 'xīn nián kuài lè' děng zhù fú de huà. Zhè ge jié rì bù jǐn shì jiā tíng tuán jù de shí jiān, yě shì jì chéng hé fā yáng zhōng huá wén huà de zhòng yào shí kè.",
            japaneseTranslation: "春節は中国で最も重要な伝統的な祭日で、中国の新年とも呼ばれます。毎年旧暦の正月1日が春節の初日です。この特別な日に、家族全員が集まって年越し料理を食べ、花火を打ち上げ、春聯を貼ります。子供たちは長輩からお年玉をもらいます。春節の期間中、人々は互いに新年の挨拶をし、「恭喜発財」「新年快楽」などの祝福の言葉を言います。この祭日は家族団らんの時間であるだけでなく、中華文化を継承し発展させる重要な時でもあります。",
            audioFileName: "long_text_spring_festival.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "传统节日", pinyin: "chuántǒng jiérì", meaning: "伝統的な祭日", contextSentence: "春节是中国最重要的传统节日"),
                ChineseLongText.KeyWord(word: "农历", pinyin: "nónglì", meaning: "旧暦", contextSentence: "每年农历正月初一"),
                ChineseLongText.KeyWord(word: "年夜饭", pinyin: "niányèfàn", meaning: "年越し料理", contextSentence: "全家人会聚在一起吃年夜饭"),
                ChineseLongText.KeyWord(word: "红包", pinyin: "hóngbāo", meaning: "お年玉", contextSentence: "孩子们会收到长辈给的红包"),
                ChineseLongText.KeyWord(word: "团聚", pinyin: "tuánjù", meaning: "団らん", contextSentence: "家庭团聚的时间")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「也叫做」の用法",
                    explanation: "「也叫做」は「〜とも呼ばれる」という意味で使われます",
                    examples: ["春节也叫做中国新年", "这个地方也叫做天堂", "他也叫做小明"]
                ),
                ChineseLongText.GrammarPoint(
                    point: "「不仅...也...」の構文",
                    explanation: "「〜だけでなく、〜でもある」という意味で使われます",
                    examples: ["这个节日不仅是家庭团聚的时间，也是继承文化的时刻", "他不仅聪明，也很努力", "这里不仅风景美，也很安静"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "春節は旧暦の何月何日ですか？",
                    options: ["12月31日", "1月1日", "正月初一", "正月十五"],
                    correctAnswer: "正月初一",
                    explanation: "「每年农历正月初一是春节的第一天」から正月初一であることがわかります。",
                    type: .multipleChoice
                )
            ]
        )
    }
    
    private func createSampleText3() -> ChineseLongText {
        return ChineseLongText(
            title: "現代ビジネスの挑戦",
            category: .business,
            level: .advanced,
            chineseText: "在当今全球化的商业环境中，企业面临着前所未有的挑战和机遇。数字化转型已经成为企业生存和发展的关键因素。许多传统企业正在努力适应新技术，包括人工智能、大数据分析和云计算等。这些技术不仅改变了企业的运营模式，也重新定义了客户体验。成功的企业必须具备敏捷性和创新能力，能够快速响应市场变化。同时，可持续发展和社会责任也越来越受到重视，消费者更倾向于选择有环保意识的品牌。",
            pinyinText: "Zài dāng jīn quán qiú huà de shāng yè huán jìng zhōng, qǐ yè miàn lín zhe qián suǒ wèi yǒu de tiǎo zhàn hé jī yù. Shù zì huà zhuǎn xíng yǐ jīng chéng wéi qǐ yè shēng cún hé fā zhǎn de guān jiàn yīn sù. Xǔ duō chuán tǒng qǐ yè zhèng zài nǔ lì shì yìng xīn jì shù, bāo kuò réng gōng zhì néng, dà shù jù fēn xī hé yún jì suàn děng. Zhè xiē jì shù bù jǐn gǎi biàn le qǐ yè de yùn yíng mó shì, yě chóng xīn dìng yì le kè hù tǐ yàn. Chéng gōng de qǐ yè bì xū jù bèi mǐn jié xìng hé chuàng xīn néng lì, néng gòu kuài sù xiǎng yìng shì chǎng biàn huà. Tóng shí, kě chí xù fā zhǎn hé shè huì zé rèn yě yuè lái yuè shòu dào zhòng shì, xiāo fèi zhě gèng qīng xiàng yú xuǎn zé yǒu huán bǎo yì shí de pǐn pái.",
            japaneseTranslation: "今日のグローバル化したビジネス環境において、企業は前例のない挑戦と機会に直面しています。デジタル変革は既に企業の生存と発展の重要な要因となっています。多くの伝統的な企業が人工知能、ビッグデータ分析、クラウドコンピューティングなどの新技術に適応しようと努力しています。これらの技術は企業の運営モデルを変えただけでなく、顧客体験も再定義しました。成功する企業は機敏性と革新能力を備え、市場の変化に迅速に対応できなければなりません。同時に、持続可能な発展と社会的責任もますます重視されており、消費者は環境意識のあるブランドを選ぶ傾向が強くなっています。",
            audioFileName: "long_text_business.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "全球化", pinyin: "quánqiúhuà", meaning: "グローバル化", contextSentence: "在当今全球化的商业环境中"),
                ChineseLongText.KeyWord(word: "数字化转型", pinyin: "shùzìhuà zhuǎnxíng", meaning: "デジタル変革", contextSentence: "数字化转型已经成为关键因素"),
                ChineseLongText.KeyWord(word: "人工智能", pinyin: "réngōng zhìnéng", meaning: "人工知能", contextSentence: "包括人工智能、大数据分析"),
                ChineseLongText.KeyWord(word: "可持续发展", pinyin: "kěchíxù fāzhǎn", meaning: "持続可能な発展", contextSentence: "可持续发展和社会责任"),
                ChineseLongText.KeyWord(word: "环保意识", pinyin: "huánbǎo yìshí", meaning: "環境意識", contextSentence: "有环保意识的品牌")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「前所未有」の用法",
                    explanation: "「前例のない、今まで見たことがない」という意味の成語です",
                    examples: ["前所未有的挑战", "前所未有的机会", "前所未有的成就"]
                ),
                ChineseLongText.GrammarPoint(
                    point: "「不仅...也...」の高級用法",
                    explanation: "複雑な文脈での「〜だけでなく、〜でもある」の使用",
                    examples: ["这些技术不仅改变了运营模式，也重新定义了客户体验"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "現代企業が直面している主な挑戦は何ですか？",
                    options: nil,
                    correctAnswer: "デジタル変革、市場の変化への対応、持続可能な発展",
                    explanation: "文章全体から、デジタル変革、市場への迅速な対応、持続可能な発展が主要な挑戦として挙げられています。",
                    type: .comprehension
                )
            ]
        )
    }
    
    private func createSampleText4() -> ChineseLongText {
        return ChineseLongText(
            title: "中国の美食文化",
            category: .food,
            level: .beginner,
            chineseText: "中国菜有八大菜系，分别是川菜、鲁菜、粤菜、苏菜、浙菜、闽菜、湘菜和徽菜。每个菜系都有自己的特色。川菜以麻辣著称，鲁菜注重鲜香，粤菜讲究清淡，苏菜偏甜。中国人常说民以食为天，这说明食物在中国文化中的重要性。无论是家庭聚餐还是节日庆祝，美食都是不可缺少的元素。",
            pinyinText: "Zhōngguócài yǒu bā dà càixì, fēnbié shì chuāncài, lǔcài, yuècài, sūcài, zhècài, mǐncài, xiāngcài hé huīcài. Měi ge càixì dōu yǒu zìjǐ de tèsè. Chuāncài yǐ málà zhùchēng, lǔcài zhùzhòng xiānxiāng, yuècài jiǎngqiú qīngdàn, sūcài piān tián. Zhōngguórén cháng shuō 'mín yǐ shí wéi tiān', zhè shuōmíng shíwù zài Zhōngguó wénhuà zhōng de zhòngyàoxìng. Wúlùn shì jiātíng jùcān háishì jiérì qìngzhù, měishí dōu shì bùkě quēshǎo de yuánsù.",
            japaneseTranslation: "中国料理には八大料理系統があり、それぞれ四川料理、山東料理、広東料理、江蘇料理、浙江料理、福建料理、湖南料理、安徽料理です。各料理系統にはそれぞれの特色があります。四川料理は麻辣で有名、山東料理は鮮やかな香りを重視、広東料理は淡白さを重視、江蘇料理は甘めです。中国人はよく「民は食を天とする」と言い、これは中国文化における食べ物の重要性を示しています。家族の食事でも祝日の祝賀でも、美食は欠かせない要素です。",
            audioFileName: "long_text_food.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "菜系", pinyin: "càixì", meaning: "料理系統", contextSentence: "中国菜有八大菜系"),
                ChineseLongText.KeyWord(word: "特色", pinyin: "tèsè", meaning: "特色", contextSentence: "每个菜系都有自己的特色"),
                ChineseLongText.KeyWord(word: "麻辣", pinyin: "málà", meaning: "痺れて辛い", contextSentence: "川菜以麻辣著称"),
                ChineseLongText.KeyWord(word: "清淡", pinyin: "qīngdàn", meaning: "淡白", contextSentence: "粤菜讲究清淡")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「以...著称」の用法",
                    explanation: "「〜で有名である」という意味を表します",
                    examples: ["川菜以麻辣著称", "这个地方以风景著称"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "中国料理は何大料理系統に分かれますか？",
                    options: ["六大", "八大", "十大", "十二大"],
                    correctAnswer: "八大",
                    explanation: "文中に「中国菜有八大菜系」とあります。",
                    type: .multipleChoice
                )
            ]
        )
    }
    
    private func createSampleText5() -> ChineseLongText {
        return ChineseLongText(
            title: "北京胡同の風情",
            category: .culture,
            level: .intermediate,
            chineseText: "北京的胡同是这座古城的灵魂。胡同起源于元代，至今已有七百多年的历史。走在胡同里，你能感受到老北京的生活气息。灰色的砖墙，红色的大门，门前的石狮子，院子里的槐树，都诉说着历史的故事。虽然现代化的进程让许多胡同消失了，但政府正在努力保护剩余的胡同，让这些珍贵的文化遗产得以传承。",
            pinyinText: "Běijīng de hútòng shì zhè zuò gǔchéng de línghún. Hútòng qǐyuán yú Yuándài, zhìjīn yǐ yǒu qībǎi duō nián de lìshǐ. Zǒu zài hútòng lǐ, nǐ néng gǎnshòu dào lǎo Běijīng de shēnghuó qìxī. Huīsè de zhuānqiáng, hóngsè de dàmén, ménqián de shíshīzi, yuànzi lǐ de huáishù, dōu sùshuō zhe lìshǐ de gùshi. Suīrán xiàndàihuà de jìnchéng ràng xǔduō hútòng xiāoshī le, dàn zhèngfǔ zhèngzài nǔlì bǎohù shèngyú de hútòng, ràng zhèxiē zhēnguì de wénhuà yíchǎn déyǐ chuánchéng.",
            japaneseTranslation: "北京の胡同はこの古都の魂です。胡同は元代に起源し、今日まで七百年余りの歴史があります。胡同を歩けば、古い北京の生活の息づかいを感じることができます。灰色のレンガ壁、赤い門、門前の石獅子、中庭の槐の木、すべてが歴史の物語を語っています。現代化の進展により多くの胡同が消失しましたが、政府は残された胡同の保護に努力し、これらの貴重な文化遺産を継承させようとしています。",
            audioFileName: "long_text_hutong.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "胡同", pinyin: "hútòng", meaning: "胡同（北京の路地）", contextSentence: "北京的胡同是这座古城的灵魂"),
                ChineseLongText.KeyWord(word: "起源", pinyin: "qǐyuán", meaning: "起源", contextSentence: "胡同起源于元代"),
                ChineseLongText.KeyWord(word: "气息", pinyin: "qìxī", meaning: "息づかい", contextSentence: "老北京的生活气息"),
                ChineseLongText.KeyWord(word: "文化遗产", pinyin: "wénhuà yíchǎn", meaning: "文化遺産", contextSentence: "珍贵的文化遗产")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「让...得以...」の構文",
                    explanation: "「〜を〜できるようにする」という使役の意味",
                    examples: ["让这些珍贵的文化遗产得以传承", "让我们得以了解历史"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "胡同の歴史はどのくらいですか？",
                    options: nil,
                    correctAnswer: "七百年余り",
                    explanation: "「至今已有七百多年的历史」から七百年余りであることがわかります。",
                    type: .comprehension
                )
            ]
        )
    }
    
    private func createSampleText6() -> ChineseLongText {
        return ChineseLongText(
            title: "大学キャンパス生活",
            category: .education,
            level: .beginner,
            chineseText: "大学生活丰富多彩。每天早上八点开始上课，下午通常有实验或者讨论课。除了学习，同学们还积极参加各种社团活动。有的人加入音乐社，有的人参加体育队，还有人选择志愿服务。周末的时候，大家会去图书馆看书，或者和朋友一起逛街看电影。宿舍生活也很有趣，室友们会一起做饭、聊天、玩游戏。这段美好的时光会成为人生中珍贵的回忆。",
            pinyinText: "Dàxué shēnghuó fēngfù duōcǎi. Měitiān zǎoshang bā diǎn kāishǐ shàngkè, xiàwǔ tōngcháng yǒu shíyàn huòzhě tǎolùnkè. Chúle xuéxí, tóngxuémen hái jījí cānjiā gèzhǒng shètuán huódòng. Yǒu de rén jiārù yīnyuè shè, yǒu de rén cānjiā tǐyù duì, hái yǒu rén xuǎnzé zhìyuàn fúwù. Zhōumò de shíhou, dàjiā huì qù túshūguǎn kànshū, huòzhě hé péngyǒu yīqǐ guàngjiē kàn diànyǐng. Sùshè shēnghuó yě hěn yǒuqù, shìyǒumen huì yīqǐ zuòfàn, liáotiān, wán yóuxì. Zhè duàn měihǎo de shíguāng huì chéngwéi rénshēng zhōng zhēnguì de huíyì.",
            japaneseTranslation: "大学生活は豊富多彩です。毎日朝8時から授業が始まり、午後は通常実験や討論の授業があります。勉強以外にも、学生たちは積極的に様々なサークル活動に参加します。音楽サークルに参加する人、体育部に参加する人、ボランティア活動を選ぶ人もいます。週末には、図書館で読書をしたり、友達と一緒に買い物や映画鑑賞をしたりします。寮生活も面白く、ルームメイトと一緒に料理、おしゃべり、ゲームをします。この美しい時間は人生の貴重な思い出となります。",
            audioFileName: "long_text_campus.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "丰富多彩", pinyin: "fēngfù duōcǎi", meaning: "豊富多彩", contextSentence: "大学生活丰富多彩"),
                ChineseLongText.KeyWord(word: "社团", pinyin: "shètuán", meaning: "サークル", contextSentence: "参加各种社团活动"),
                ChineseLongText.KeyWord(word: "志愿服务", pinyin: "zhìyuàn fúwù", meaning: "ボランティア活动", contextSentence: "选择志愿服务"),
                ChineseLongText.KeyWord(word: "宿舍", pinyin: "sùshè", meaning: "寮", contextSentence: "宿舍生活也很有趣")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「有的...有的...还有...」の構文",
                    explanation: "複数の選択肢や例を列挙する時に使用",
                    examples: ["有的人加入音乐社，有的人参加体育队，还有人选择志愿服务"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "大学で授業は何時から始まりますか？",
                    options: ["7時", "8時", "9時", "10時"],
                    correctAnswer: "8時",
                    explanation: "「每天早上八点开始上课」から8時であることがわかります。",
                    type: .multipleChoice
                )
            ]
        )
    }
    
    private func createSampleText7() -> ChineseLongText {
        return ChineseLongText(
            title: "中国の環境保護",
            category: .science,
            level: .advanced,
            chineseText: "近年来，中国政府高度重视环境保护工作。为了应对气候变化和空气污染问题，中国制定了严格的环保政策。政府大力推广清洁能源，包括太阳能、风能和水能。同时，加强对工业排放的监管，关闭了许多高污染企业。在交通方面，推广电动汽车，建设完善的公共交通系统。此外，还实施了垃圾分类制度，提高民众的环保意识。经过多年努力，中国的环境质量已经明显改善。",
            pinyinText: "Jìnnián lái, Zhōngguó zhèngfǔ gāodù zhòngshì huánjìng bǎohù gōngzuò. Wèile yìngduì qìhòu biànhuà hé kōngqì wūrǎn wèntí, Zhōngguó zhìdìng le yángé de huánbǎo zhèngcè. Zhèngfǔ dàlì tuīguǎng qīngjié néngyuán, bāokuò tàiyángnéng, fēngnéng hé shuǐnéng. Tóngshí, jiāqiáng duì gōngyè páifàng de jiānguǎn, guānbì le xǔduō gāo wūrǎn qǐyè. Zài jiāotōng fāngmiàn, tuīguǎng diàndòng qìchē, jiànshè wánshàn de gōnggòng jiāotōng xìtǒng. Cǐwài, hái shíshī le lājī fēnlèi zhìdù, tígāo mínzhòng de huánbǎo yìshí. Jīngguò duōnián nǔlì, Zhōngguó de huánjìng zhìliàng yǐjīng míngxiǎn gǎishàn.",
            japaneseTranslation: "近年、中国政府は環境保護作業を高度に重視しています。気候変動と大気汚染問題に対応するため、中国は厳格な環境保護政策を制定しました。政府は太陽エネルギー、風力エネルギー、水力エネルギーを含むクリーンエネルギーを大いに推進しています。同時に、工業排出の監督管理を強化し、多くの高汚染企業を閉鎖しました。交通面では、電気自動車を推進し、完備した公共交通システムを建設しています。さらに、ゴミ分別制度を実施し、民衆の環境保護意識を向上させています。多年の努力を経て、中国の環境品質は明らかに改善されています。",
            audioFileName: "long_text_environment.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "环境保护", pinyin: "huánjìng bǎohù", meaning: "環境保護", contextSentence: "重视环境保护工作"),
                ChineseLongText.KeyWord(word: "气候变化", pinyin: "qìhòu biànhuà", meaning: "気候変動", contextSentence: "应对气候变化"),
                ChineseLongText.KeyWord(word: "清洁能源", pinyin: "qīngjié néngyuán", meaning: "クリーンエネルギー", contextSentence: "推广清洁能源"),
                ChineseLongText.KeyWord(word: "垃圾分类", pinyin: "lājī fēnlèi", meaning: "ゴミ分別", contextSentence: "实施垃圾分类制度")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「为了...」の目的表現",
                    explanation: "「〜のために」という目的を表す",
                    examples: ["为了应对气候变化", "为了保护环境"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "中国が推進しているクリーンエネルギーには何がありますか？",
                    options: nil,
                    correctAnswer: "太陽エネルギー、風力エネルギー、水力エネルギー",
                    explanation: "「包括太阳能、风能和水能」から、これら3つがクリーンエネルギーとして挙げられています。",
                    type: .comprehension
                )
            ]
        )
    }
    
    private func createSampleText8() -> ChineseLongText {
        return ChineseLongText(
            title: "オンラインショッピング",
            category: .business,
            level: .intermediate,
            chineseText: "网购已经成为现代生活的重要组成部分。人们可以在家里轻松购买各种商品，从日用品到电子产品，应有尽有。网购的优点很多：24小时营业，价格透明，选择丰富。但是也有一些缺点，比如无法亲自体验商品，物流可能延迟，退换货比较麻烦。为了保护消费者权益，政府制定了相关法律法规。现在的网购平台也越来越注重用户体验和服务质量。",
            pinyinText: "Wǎnggòu yǐjīng chéngwéi xiàndài shēnghuó de zhòngyào zǔchéng bùfen. Rénmen kěyǐ zài jiālǐ qīngsōng gòumǎi gèzhǒng shāngpǐn, cóng rìyòngpǐn dào diànzǐ chǎnpǐn, yīngyǒujìnyǒu. Wǎnggòu de yōudiǎn hěnduō: èrshísì xiǎoshí yíngyè, jiàgé tòumíng, xuǎnzé fēngfù. Dànshì yě yǒu yīxiē quēdiǎn, bǐrú wúfǎ qīnzì tǐyàn shāngpǐn, wùliú kěnéng yánchí, tuìhuànhuò bǐjiào máfan. Wèile bǎohù xiāofèizhě quányì, zhèngfǔ zhìdìng le xiāngguān fǎlǜ fǎguī. Xiànzài de wǎnggòu píngtái yě yuèláiyuè zhùzhòng yònghù tǐyàn hé fúwù zhìliàng.",
            japaneseTranslation: "ネットショッピングは既に現代生活の重要な構成部分となっています。人々は家で楽に様々な商品を購入でき、日用品から電子製品まで、何でも揃っています。ネットショッピングの利点は多く、24時間営業、価格透明、選択豊富です。しかし欠点もあり、例えば商品を直接体験できない、物流が遅延する可能性がある、返品交換が面倒などです。消費者の権益を保護するため、政府は関連法律法規を制定しました。現在のネットショッピングプラットフォームもますますユーザー体験とサービス品質を重視しています。",
            audioFileName: "long_text_shopping.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "网购", pinyin: "wǎnggòu", meaning: "ネットショッピング", contextSentence: "网购已经成为现代生活的重要组成部分"),
                ChineseLongText.KeyWord(word: "应有尽有", pinyin: "yīngyǒujìnyǒu", meaning: "何でも揃っている", contextSentence: "从日用品到电子产品，应有尽有"),
                ChineseLongText.KeyWord(word: "消费者", pinyin: "xiāofèizhě", meaning: "消費者", contextSentence: "保护消费者权益"),
                ChineseLongText.KeyWord(word: "用户体验", pinyin: "yònghù tǐyàn", meaning: "ユーザー体験", contextSentence: "注重用户体验")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「从...到...」の範囲表現",
                    explanation: "「〜から〜まで」という範囲を表す",
                    examples: ["从日用品到电子产品", "从早到晚"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "ネットショッピングの利点として挙げられていないものは？",
                    options: ["24時間営業", "価格透明", "直接体験可能", "選択豊富"],
                    correctAnswer: "直接体験可能",
                    explanation: "「无法亲自体验商品」とあり、直接体験できないことが欠点として挙げられています。",
                    type: .multipleChoice
                )
            ]
        )
    }
    
    private func createSampleText9() -> ChineseLongText {
        return ChineseLongText(
            title: "四季の美しさ",
            category: .culture,
            level: .beginner,
            chineseText: "中国幅员辽阔，四季分明。春天万物复苏，桃花盛开，柳绿花红。夏天绿树成荫，荷花满池，蝉声阵阵。秋天硕果累累，枫叶红遍，金桂飘香。冬天雪花飞舞，梅花傲雪，银装素裹。每个季节都有独特的美景，都值得我们细细品味。古人说一年之计在于春，这体现了中国人对时间和季节的重视。",
            pinyinText: "Zhōngguó fúyuán liáokuò, sìjì fēnmíng. Chūntiān wànwù fùsū, táohuā shèngkāi, liǔlǜ huāhóng. Xiàtiān lǜshù chéngyīn, héhuā mǎnchí, chánshēng zhènzhèn. Qiūtiān shuòguǒ lěilěi, fēngyè hóngbiàn, jīnguì piāoxiāng. Dōngtiān xuěhuā fēiwǔ, méihuā àoxuě, yínzhuāng sùguǒ. Měi ge jìjié dōu yǒu dútè de měijǐng, dōu zhídé wǒmen xìxì pǐnwèi. Gǔrén shuō 'yī nián zhī jì zàiyú chūn', zhè tǐxiàn le Zhōngguórén duì shíjiān hé jìjié de zhòngshì.",
            japaneseTranslation: "中国は国土が広大で、四季がはっきりしています。春は万物が蘇り、桃の花が満開で、柳は緑、花は紅です。夏は緑の木が日陰を作り、蓮の花が池いっぱいに咲き、蝉の声が響きます。秋は実りが豊かで、もみじが山を赤く染め、金桂の香りが漂います。冬は雪の花が舞い踊り、梅の花が雪に誇り、銀世界です。各季節には独特の美しい景色があり、どれも私たちがじっくりと味わう価値があります。古人は「一年の計は春にあり」と言い、これは中国人の時間と季節への重視を表しています。",
            audioFileName: "long_text_seasons.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "幅员辽阔", pinyin: "fúyuán liáokuò", meaning: "国土が広大", contextSentence: "中国幅员辽阔"),
                ChineseLongText.KeyWord(word: "四季分明", pinyin: "sìjì fēnmíng", meaning: "四季がはっきり", contextSentence: "四季分明"),
                ChineseLongText.KeyWord(word: "万物复苏", pinyin: "wànwù fùsū", meaning: "万物が蘇る", contextSentence: "春天万物复苏"),
                ChineseLongText.KeyWord(word: "银装素裹", pinyin: "yínzhuāng sùguǒ", meaning: "銀世界", contextSentence: "银装素裹")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「值得...」の価値表現",
                    explanation: "「〜する価値がある」という意味",
                    examples: ["值得我们细细品味", "值得学习"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "「一年之計在於春」はどんな意味ですか？",
                    options: nil,
                    correctAnswer: "一年の計画は春に立てるべきだという意味",
                    explanation: "古人の言葉で、年間の計画は春に立てることの重要性を表しています。",
                    type: .comprehension
                )
            ]
        )
    }
    
    private func createSampleText10() -> ChineseLongText {
        return ChineseLongText(
            title: "健康的な生活習慣",
            category: .health,
            level: .intermediate,
            chineseText: "健康的生活方式对每个人都很重要。首先，要保持规律的作息时间，早睡早起，充足的睡眠有助于身体恢复。其次，均衡的饮食不可忽视，多吃蔬菜水果，少吃油腻食物。第三，坚持适量运动，每天至少三十分钟，可以选择跑步、游泳或者瑜伽。最后，保持良好的心理状态，学会放松，减少压力。只有身心健康，我们才能更好地工作和生活。预防胜于治疗，养成良好习惯从今天开始。",
            pinyinText: "Jiànkāng de shēnghuó fāngshì duì měi ge rén dōu hěn zhòngyào. Shǒuxiān, yào bǎochí guīlǜ de zuòxī shíjiān, zǎoshuì zǎoqǐ, chōngzú de shuìmián yǒuzhù yú shēntǐ huīfù. Qícì, jūnhéng de yǐnshí bùkě hūshì, duō chī shūcài shuǐguǒ, shǎo chī yóunì shíwù. Dìsān, jiānchí shìliàng yùndòng, měitiān zhìshǎo sānshí fēnzhōng, kěyǐ xuǎnzé pǎobù, yóuyǒng huòzhě yújiā. Zuìhòu, bǎochí liánghǎo de xīnlǐ zhuàngtài, xuéhuì fàngsōng, jiǎnshǎo yālì. Zhǐyǒu shēnxīn jiànkāng, wǒmen cái néng gèng hǎo de gōngzuò hé shēnghuó. Yùfáng shèng yú zhìliáo, yǎngchéng liánghǎo xíguàn cóng jīntiān kāishǐ.",
            japaneseTranslation: "健康的な生活スタイルは誰にとっても重要です。まず、規則正しい生活リズムを保ち、早寝早起きをし、十分な睡眠は身体の回復に役立ちます。次に、バランスの取れた食事を無視してはならず、野菜や果物を多く食べ、油っこい食べ物は控えめにします。第三に、適度な運動を継続し、毎日最低30分、ランニング、水泳、ヨガなどを選ぶことができます。最後に、良好な心理状態を保ち、リラックスすることを学び、ストレスを減らします。心身ともに健康であってこそ、私たちはより良く働き、生活することができます。予防は治療に勝る、良い習慣を今日から身につけましょう。",
            audioFileName: "long_text_health.mp3",
            keyWords: [
                ChineseLongText.KeyWord(word: "生活方式", pinyin: "shēnghuó fāngshì", meaning: "ライフスタイル", contextSentence: "健康的生活方式"),
                ChineseLongText.KeyWord(word: "作息时间", pinyin: "zuòxī shíjiān", meaning: "生活リズム", contextSentence: "规律的作息时间"),
                ChineseLongText.KeyWord(word: "均衡", pinyin: "jūnhéng", meaning: "バランス", contextSentence: "均衡的饮食"),
                ChineseLongText.KeyWord(word: "预防", pinyin: "yùfáng", meaning: "予防", contextSentence: "预防胜于治疗")
            ],
            grammarPoints: [
                ChineseLongText.GrammarPoint(
                    point: "「只有...才...」の構文",
                    explanation: "「〜してこそ、初めて〜」という条件を強調する表現",
                    examples: ["只有身心健康，我们才能更好地工作", "只有努力学习，才能取得好成绩"]
                )
            ],
            exerciseQuestions: [
                ChineseLongText.ExerciseQuestion(
                    question: "健康的な生活のために推奨される運動時間は？",
                    options: ["20分", "30分", "45分", "60分"],
                    correctAnswer: "30分",
                    explanation: "「每天至少三十分钟」から、最低30分の運動が推奨されています。",
                    type: .multipleChoice
                )
            ]
        )
    }
}
