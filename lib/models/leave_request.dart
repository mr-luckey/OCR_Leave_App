class LeaveRequest {
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String emiratesId;
  final String name;
  final String? imagePath;

  LeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.emiratesId,
    required this.name,
    this.imagePath,
  });
}
