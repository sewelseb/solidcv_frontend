import 'package:flutter/material.dart';
import 'package:solid_cv/models/User.dart';

class UserSearchList extends StatefulWidget {
  final Future<List<User>> Function(String term) onSearch;
  final void Function(User) onUserTap;
  final String hintText;
  final IconData trailingIcon;
  final String emptyMessage;
  final String errorMessage;
  final String cardTitle;
  final String? cardSubtitle;

  const UserSearchList({
    super.key,
    required this.onSearch,
    required this.onUserTap,
    this.hintText = "Search User",
    this.trailingIcon = Icons.add,
    this.emptyMessage = "No user found.",
    this.errorMessage = "Error while searching.",
    this.cardTitle = "Search for a user",
    this.cardSubtitle,
  });

  @override
  State<UserSearchList> createState() => _UserSearchListState();
}

class _UserSearchListState extends State<UserSearchList> {
  late Future<List<User>> _usersFuture;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _usersFuture = widget.onSearch('');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _usersFuture = widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      radius: const Radius.circular(18),
      thickness: 7,
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : 0, vertical: isMobile ? 10 : 32),
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 570),
              child: Card(
                color: Colors.white,
                elevation: 7,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 34,
                      vertical: isMobile ? 24 : 38),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.cardTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            color: Color(0xFF7B3FE4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.cardSubtitle != null) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            widget.cardSubtitle!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: widget.hintText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xFF7B3FE4), width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 18),
                      FutureBuilder<List<User>>(
                        future: _usersFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(22),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                widget.errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  'No user found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black45,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final users = snapshot.data!;
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => widget.onUserTap(user),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F7FF),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                            color: Colors.deepPurple.shade50, width: 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.deepPurple.shade50,
                                            radius: 21,
                                            child: const Icon(Icons.person,
                                                color: Colors.deepPurple, size: 25),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              user.getEasyName() ?? "-",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                          Icon(widget.trailingIcon,
                                              color: Colors.deepPurple.shade200,
                                              size: 22),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
