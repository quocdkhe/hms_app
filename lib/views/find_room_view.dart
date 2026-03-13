import 'package:flutter/material.dart';
import 'package:hms_app/widgets/app_drawer.dart';
import 'package:hms_app/widgets/date_time_picker.dart';

class FindRoomView extends StatefulWidget {
  const FindRoomView({super.key});

  @override
  State<FindRoomView> createState() => _FindRoomViewState();
}

class _FindRoomViewState extends State<FindRoomView> {
  String selectedRoomType = 'Normal';
  int? selectedRoomIndex;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  final TextEditingController bedNumberController = TextEditingController();
  final TextEditingController extraBedController = TextEditingController();

  @override
  void dispose() {
    bedNumberController.dispose();
    extraBedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final initialDate = isCheckIn ? (checkInDate ?? DateTime.now()) : (checkOutDate ?? checkInDate ?? DateTime.now());
    final firstDate = isCheckIn ? DateTime.now() : (checkInDate ?? DateTime.now());
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = pickedDate;
          if (checkOutDate != null && checkOutDate!.isBefore(checkInDate!)) {
            checkOutDate = null;
          }
        } else {
          checkOutDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Tìm Phòng', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check-in and Check-out
            DateTimePicker(
              label: 'Nhận phòng',
              icon: Icons.login,
              value: checkInDate == null ? 'dd/mm/yyyy' : '${checkInDate!.day.toString().padLeft(2, '0')}/${checkInDate!.month.toString().padLeft(2, '0')}/${checkInDate!.year}',
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 12),
            DateTimePicker(
              label: 'Trả phòng',
              icon: Icons.logout,
              value: checkOutDate == null ? 'dd/mm/yyyy' : '${checkOutDate!.day.toString().padLeft(2, '0')}/${checkOutDate!.month.toString().padLeft(2, '0')}/${checkOutDate!.year}',
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 24),

            // Bed Number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giường chính', style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: bedNumberController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      isDense: true,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Extra bed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Giường phụ', style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: extraBedController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      isDense: true,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Loại Phòng
            Text('Loại Phòng', style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Normal', 'VIP', 'King'].map((type) {
                final isSelected = selectedRoomType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRoomType = type;
                    });
                  },
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.onSurface),
                      color: isSelected ? colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(color: isSelected ? colorScheme.primary : colorScheme.onSurface, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Search Button
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Tìm kiếm'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colorScheme.onSurface, thickness: 1.5),
            const SizedBox(height: 24),

            // Room list
            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: selectedRoomIndex == index ? colorScheme.primary : Colors.transparent, 
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                         selectedRoomIndex = index;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image section placeholder
                        Container(
                          width: 110,
                          height: 110,
                          color: index == 0 ? colorScheme.primaryContainer : index == 1 ? colorScheme.secondaryContainer : colorScheme.tertiaryContainer,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(110, 110),
                                painter: DiagonalLinePainter(color: colorScheme.onSurface),
                              ),
                              Text(
                                'Room\nimage',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        // Content section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Phòng ${101 + index} - ${index == 0 ? 'Normal' : index == 1 ? 'VIP' : 'King'}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (selectedRoomIndex == index)
                                      Icon(Icons.check_circle, color: colorScheme.primary),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.bed,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '2 giường  •  Tầng 1',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  '500,000 VND/đêm', // formatVND placeholder
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Mô tả phòng...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Book Button
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Đặt Phòng'),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  final Color color;

  DiagonalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CheckPainter extends CustomPainter {
  final Color color;

  CheckPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(size.width * 0.15, size.width * 0.5);
    path.lineTo(size.width * 0.45, size.width * 0.8);
    path.lineTo(size.width * 0.85, size.width * 0.2);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
