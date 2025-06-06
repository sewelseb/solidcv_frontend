import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solid_cv/Views/Parameters/CompanyParameter.dart';
import 'package:solid_cv/business_layer/CompanyBll.dart';
import 'package:solid_cv/business_layer/ICompanyBll.dart';
import 'package:solid_cv/models/Company.dart';

class MyCompanies extends StatefulWidget {
  const MyCompanies({super.key});

  @override
  _MyCompaniesState createState() => _MyCompaniesState();
}

class _MyCompaniesState extends State<MyCompanies> {
  late Future<List<Company>> companies;
  final ICompanyBll _companyBll = CompanyBll();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    companies = _companyBll.getMyCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return FutureBuilder<List<Company>>(
      future: companies,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No companies found.'));
        } else {
          return ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisExtent: isSmallScreen ? 130 : 110,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 16,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final company = snapshot.data![index];
                        return _CompanyCard(company: company);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(
          context,
          "/my-company-administration",
          arguments: CompanyParameter(id: company.id!),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurple.shade50,
                backgroundImage: NetworkImage(company.getProfilePicture()),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      company.name ?? "Unnamed Company",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.getFullAddress() ?? "",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (company.email != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          company.email!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black38),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Color(0xFF7B3FE4), size: 23),
            ],
          ),
        ),
      ),
    );
  }
}
