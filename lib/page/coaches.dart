import 'package:dabel_sport/controller/AnimationController.dart';
import 'package:dabel_sport/controller/CoachController.dart';
import 'package:dabel_sport/controller/SettingController.dart';
import 'package:dabel_sport/helper/helpers.dart';
import 'package:dabel_sport/helper/styles.dart';
import 'package:dabel_sport/page/coach_create.dart';
import 'package:dabel_sport/widget/filter_coaches.dart';
import 'package:dabel_sport/widget/grid_coach.dart';
import 'package:dabel_sport/widget/search_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/loader.dart';

class CoachesPage extends StatelessWidget {
  late CoachController controller;
  late MyAnimationController animationController;
  late Style styleController;
  late SettingController settingController;
  ScrollController scrollController = ScrollController();
  late MaterialColor colors;

  CoachesPage({Key? key, Map<String, String>? initFilter}) {
    controller = Get.find<CoachController>();
    settingController = Get.find<SettingController>();
    styleController = Get.find<Style>();
    colors = styleController.cardCoachColors;
    animationController = Get.find<MyAnimationController>();
    controller.filterController.set(initFilter ?? {});
    controller.getData(param: {'page': 'clear'});
    scrollController.addListener(() {
      if (scrollController.position.pixels + 50 >
          scrollController.position.maxScrollExtent) {
        if (!controller.loading) {
          controller.getData();
        }
      }
    });
    controller.filterController.change(true, status: RxStatus.success());

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Future.delayed(Duration(seconds: 2), () {
      //   Get.to(
      //       CoachDetails(
      //           data: controller.data[0],
      //           controller: controller,
      //           settingController: settingController,
      //           styleController: styleController,
      //           colors: colors),
      //       transition: Transition.circularReveal,
      //       duration: Duration(milliseconds: 400));
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// appBar: AppBar(actions: [
//   IconButton(onPressed:()=> showSearch(context: context, delegate: SearchBar()), icon: Icon(Icons.search))
// ]),

      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => controller.getData(param: {'page': 'clear'}),
        child: Container(
          decoration: BoxDecoration(gradient: styleController.splashBackground),
          child: SafeArea(
            child: Column(
              children: [
                SearchSection(
                  filterSection: CoachFilterSection(
                    controller: controller,
                  ),
                  controller: controller,
                  hintText: controller.filterController.searchHintText,
                ),
                Expanded(
                  child: controller.obx((data) {
                    if (styleController.gridLength < 2)
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder( physics: AlwaysScrollableScrollPhysics(),
                              controller: scrollController,
                              padding: EdgeInsets.zero,
                              shrinkWrap: false,
                              itemCount: data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GridCoach(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  styleController: styleController,
                                  colors: colors,
                                );
                              },
                            ),
                          ),
                          controller.loading ? Loader() : Center()
                        ],
                      );
                    else
                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: false,
                              controller: scrollController,
                              itemCount: data!.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          styleController.gridLength,
                                      childAspectRatio: 1.5),
                              itemBuilder: (BuildContext context, int index) {
                                return GridCoach(
                                  data: data[index],
                                  controller: controller,
                                  settingController: settingController,
                                  styleController: styleController,
                                  colors: colors,
                                );
                              },
                            ),
                          ),
                          controller.loading ? Loader() : Center()
                        ],
                      );
                  },
                      onEmpty: Center(
                        child: Text(
                          "no_result".tr,
                          style: styleController.textBigLightStyle,
                        ),
                      ),
                      onLoading: Loader()),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {    Get.to(CoachCreate())?.then((result) {
          if (result == 'done') {
            // settingController.currentPageIndex = 4;
            settingController.refresh();
            Get.find<Helper>().showToast(
                msg:
                'registered_successfully'.tr,
                status: 'success');
          }
        });},
        backgroundColor:colors[900],
        child: Icon(Icons.add),
      ),
    );
  }
}