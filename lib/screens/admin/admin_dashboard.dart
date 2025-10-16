import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();
  
  late TabController _tabController;
  Map<String, double>? _overallStats;
  List<AttendanceModel> _recentAttendance = [];
  List<UserModel> _allStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final stats = await _attendanceService.getAttendanceStats();
    final recent = await _attendanceService.getAttendanceRecords();
    final students = await _attendanceService.getRegisteredStudents();
    
    // Sort recent by timestamp
    recent.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _overallStats = stats;
      _recentAttendance = recent.take(10).toList();
      _allStudents = students;
      _isLoading = false;
    });
  }

  Future<void> _handleSignOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${user?.name ?? 'Administrator'}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined)),
            Tab(text: 'Students', icon: Icon(Icons.people_outline)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildStudentsTab(),
                _buildReportsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            if (_overallStats != null) ...[
              _buildStatsSection(),
              const SizedBox(height: 24),
            ],

            // Today's Summary
            _buildTodaySummary(),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Students (${_allStudents.length})',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Export students list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Students List
            if (_allStudents.isEmpty)
              _buildEmptyState(
                'No students registered',
                'Students will appear here when they create accounts',
                Icons.people_outlined,
              )
            else
              ..._allStudents.map((student) => _buildStudentCard(student)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Reports',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Report Cards
            _buildReportCard(
              'Daily Report',
              'View today\'s attendance summary',
              Icons.today_outlined,
              Colors.blue,
              () => _showDailyReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Weekly Report',
              'View this week\'s attendance trends',
              Icons.date_range_outlined,
              Colors.green,
              () => _showWeeklyReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Monthly Report',
              'View monthly attendance statistics',
              Icons.calendar_month_outlined,
              Colors.orange,
              () => _showMonthlyReport(),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              'Export All Data',
              'Download complete attendance database',
              Icons.download_outlined,
              Colors.purple,
              () => _exportAllData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _overallStats!;
    final percentage = stats['attendancePercentage'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'School Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Overall Attendance Rate
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Attendance Rate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.school,
                size: 48,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Stats Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Records',
              '${stats['totalDays']?.toInt() ?? 0}',
              Icons.assignment_outlined,
              Colors.blue,
            ),
            _buildStatCard(
              'Present',
              '${stats['presentDays']?.toInt() ?? 0}',
              Icons.check_circle_outlined,
              Colors.green,
            ),
            _buildStatCard(
              'Late',
              '${stats['lateDays']?.toInt() ?? 0}',
              Icons.access_time,
              Colors.orange,
            ),
            _buildStatCard(
              'Absent',
              '${stats['absentDays']?.toInt() ?? 0}',
              Icons.cancel_outlined,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySummary() {
    final today = DateTime.now();
    final todayRecords = _recentAttendance.where(
      (record) => _isSameDate(record.date, today)
    ).toList();
    
    final presentToday = todayRecords.where((r) => r.status == AttendanceStatus.present).length;
    final lateToday = todayRecords.where((r) => r.status == AttendanceStatus.late).length;
    final absentToday = todayRecords.where((r) => r.status == AttendanceStatus.absent).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, MMM dd, yyyy').format(today),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildTodayStatCard('Present', presentToday, Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTodayStatCard('Late', lateToday, Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTodayStatCard('Absent', absentToday, Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_recentAttendance.isEmpty)
          _buildEmptyState(
            'No recent activity',
            'Attendance records will appear here',
            Icons.history_outlined,
          )
        else
          ..._recentAttendance.take(5).map((record) => _buildActivityItem(record)).toList(),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(UserModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              student.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  student.email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (student.teacherId != null)
                  Text(
                    'Teacher ID: ${student.teacherId}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                student.userType.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(student.createdAt),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(AttendanceModel record) {
    Color statusColor = _getStatusColor(record.status);
    IconData statusIcon = _getStatusIcon(record.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${record.studentName} marked ${record.status.name}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            DateFormat('MMM dd, HH:mm').format(record.timestamp),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.absent:
        return Icons.cancel;
    }
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showDailyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily report feature coming soon!')),
    );
  }

  void _showWeeklyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Weekly report feature coming soon!')),
    );
  }

  void _showMonthlyReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monthly report feature coming soon!')),
    );
  }

  void _exportAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }
}