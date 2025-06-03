import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _faqs = [
    {
      'question': 'كيف يمكنني تتبع طلبي؟',
      'answer': 'يمكنك تتبع طلبك من خلال الذهاب إلى قسم "طلباتي" واختيار الطلب المطلوب. ستجد تفاصيل حالة الطلب وتاريخ التوصيل المتوقع.',
    },
    {
      'question': 'ما هي طرق الدفع المتاحة؟',
      'answer': 'نقبل الدفع ببطاقات الائتمان (فيزا، ماستركارد) والمحافظ الإلكترونية. يمكنك إضافة طرق الدفع من خلال قسم "طرق الدفع" في الملف الشخصي.',
    },
    {
      'question': 'كيف يمكنني تغيير عنوان التوصيل؟',
      'answer': 'يمكنك تغيير عنوان التوصيل من خلال الذهاب إلى "عناويني" في الملف الشخصي. يمكنك إضافة عنوان جديد أو تعديل العناوين الموجودة.',
    },
    {
      'question': 'ما هي مدة التوصيل المتوقعة؟',
      'answer': 'تختلف مدة التوصيل حسب المنطقة، عادة ما تكون من 2-5 أيام عمل. يمكنك معرفة مدة التوصيل المتوقعة عند إضافة المنتج إلى سلة المشتريات.',
    },
    {
      'question': 'كيف يمكنني إلغاء طلب؟',
      'answer': 'يمكنك إلغاء الطلب من خلال قسم "طلباتي" قبل بدء عملية الشحن. إذا كان الطلب قيد المعالجة، يمكنك الضغط على زر "إلغاء الطلب".',
    },
    {
      'question': 'كيف يمكنني إرجاع منتج؟',
      'answer': 'يمكنك إرجاع المنتج خلال 14 يوم من تاريخ الاستلام. قم بزيارة قسم "طلباتي" واختر الطلب الذي تريد إرجاعه، ثم اتبع الخطوات المطلوبة.',
    },
    {
      'question': 'هل يمكنني تغيير موعد التوصيل؟',
      'answer': 'نعم، يمكنك تغيير موعد التوصيل قبل 24 ساعة من موعد التوصيل المحدد. قم بزيارة تفاصيل الطلب واختر "تغيير موعد التوصيل".',
    },
    {
      'question': 'كيف يمكنني التواصل مع خدمة العملاء؟',
      'answer': 'يمكنك التواصل مع خدمة العملاء من خلال قسم "المساعدة" واختيار "تواصل معنا". كما يمكنك الاتصال على الرقم 920000000.',
    },
  ];

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs.where((faq) {
      return faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('المساعدة'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          _buildContactSupport(),
          const SizedBox(height: 20),
          _buildFaqSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن سؤال...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            NeumorphicConstants.gradientStart,
            NeumorphicConstants.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            'تواصل مع الدعم الفني',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'نحن هنا لمساعدتك على مدار الساعة',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContactButton(
                icon: Icons.phone,
                label: 'اتصال',
                onTap: () => _makePhoneCall(),
              ),
              const SizedBox(width: 16),
              _buildContactButton(
                icon: Icons.chat,
                label: 'محادثة',
                onTap: () => _startChat(),
              ),
              const SizedBox(width: 16),
              _buildContactButton(
                icon: Icons.email,
                label: 'بريد',
                onTap: () => _sendEmail(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: NeumorphicConstants.gradientStart,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: NeumorphicConstants.gradientStart,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأسئلة الشائعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        if (_filteredFaqs.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد نتائج للبحث',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          ..._filteredFaqs.map((faq) => _buildFaqItem(faq['question']!, faq['answer']!)),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() {
    // TODO: Implement phone call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة خاصية الاتصال قريباً'),
      ),
    );
  }

  void _startChat() {
    // TODO: Implement chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة خاصية المحادثة قريباً'),
      ),
    );
  }

  void _sendEmail() {
    // TODO: Implement email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة خاصية البريد الإلكتروني قريباً'),
      ),
    );
  }
} 