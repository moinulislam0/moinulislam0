import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwells/core/constant/route_names.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010702),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xff031409),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.settingScreen);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xff031409),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Info Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/images/profile1.png",
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ludovic Migneault",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: Color(0xff00d09c),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Victoria Island",
                                style: TextStyle(
                                  color: Color(0xff00d09c),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Local Score: 120",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Stats
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildStatBox("20 Shots Given"),
                  _buildStatBox("20 Echoes Received"),
                  _buildStatBox("20 Vibe Score"),
                ],
              ),

              const SizedBox(height: 30),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTab(
                    icon: Icons.format_list_bulleted,
                    label: "All",
                    isActive: true,
                  ),
                  const SizedBox(width: 24),
                  _buildTab(
                    icon: Icons.warning_amber,
                    label: "Concerns",
                    isActive: false,
                  ),
                  const SizedBox(width: 24),
                  _buildTab(
                    icon: Icons.lightbulb_outline,
                    label: "Idea",
                    isActive: false,
                  ),
                  const SizedBox(width: 24),
                  _buildTab(
                    icon: Icons.chat_bubble_outline,
                    label: "Goss",
                    isActive: false,
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // Post Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.otherUserProfile,
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              "assets/images/profile1.png",
                              height: 45,
                              width: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Christopher Campbell",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "2m ago",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          "Victoria Island",
                          style: TextStyle(
                            color: Color(0xff00d09c),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "The traffic lights at Main Street have been broken for three days now. "
                      "Someone needs to fix this before there's an accident!!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: const [
                        _ReactionButton(
                          icon: Icons.favorite_border,
                          count: "56",
                        ),
                        SizedBox(width: 24),
                        _ReactionButton(
                          icon: Icons.chat_bubble_outline,
                          count: "6",
                        ),
                        SizedBox(width: 24),
                        _ReactionButton(icon: Icons.share, count: "6"),
                        Spacer(),
                        Icon(Icons.bookmark_border, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // STAT BOX WIDGET
  Widget _buildStatBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xff1A1A1A)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      children: [
        Icon(icon, color: isActive ? const Color(0xff00d09c) : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xff00d09c) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final String count;

  const _ReactionButton({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 6),
        Text(count, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
