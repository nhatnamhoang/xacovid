import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infowindow/shared/model/covid_data.dart';
import 'package:infowindow/shared/style/appTheme.dart';
import 'package:intl/intl.dart';

class HotelListView extends StatelessWidget {
  final bool isShowDate;
  final VoidCallback callback;
  final CovidData covidData;


  const HotelListView(
      {Key key,
        this.covidData,
        this.callback,
        this.isShowDate: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.getTheme().backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              offset: Offset(4, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: AspectRatio(
            aspectRatio: 2.7,
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 0.7,
                      child: Image.asset('assets/covid.png'),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width >= 360
                                ? 5
                                : 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              covidData.province,
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5,),
                            Text(
                              '${covidData.distance.toStringAsFixed(3)} km',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xffd9a953),
                              ),
                            ),
                            SizedBox(height: 5,),
//                            Expanded(
//                              child: SizedBox(),
//                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        RichText(
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.body1,
                                            children: [
                                              WidgetSpan(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                  child: Icon(
                                                    FontAwesomeIcons
                                                        .mapMarkerAlt,
                                                    size: 12,
                                                    color: AppTheme.getTheme()
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                              TextSpan(text: covidData.address, style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey
                                                      .withOpacity(
                                                      0.8))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: AppTheme.getTheme()
                        .primaryColor
                        .withOpacity(0.1),
                    onTap: () {
                      try {
                        callback();
                      } catch (e) {}
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class HotelListData {
  String imagePath;
  String titleTxt;
  String subTxt;
  String dateTxt;
  String roomSizeTxt;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;

  HotelListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.subTxt = "",
    this.dateTxt = "",
    this.roomSizeTxt = "",
    this.dist = 1.8,
    this.reviews = 80,
    this.rating = 4.5,
    this.perNight = 180,
    this.isSelected = false,
  });

  static List<HotelListData> hotelList = [
    HotelListData(
      imagePath: 'assets/images/place.png',
      titleTxt: 'Chung cư quân 11 ',
      subTxt: '2,4km',
      dist: 2.0,
      reviews: 80,
      rating: 4.4,
      perNight: 180,
      roomSizeTxt: '1 Room - 2 Adults',
      isSelected: true,
      dateTxt:
      '${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 2)))} - ${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 8)))}',
    ),
    HotelListData(
      imagePath: 'assets/images/place.png',
      titleTxt: 'Chung cư quân 11 ',
      subTxt: '2,4km',
      dist: 4.0,
      reviews: 74,
      rating: 4.5,
      perNight: 200,
      roomSizeTxt: '1 Room - 3 Adults',
      isSelected: false,
      dateTxt:
      '${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 1)))} - ${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 6)))}',
    ),
    HotelListData(
      imagePath: 'assets/images/place.png',
      titleTxt: 'Chung cư quân 11 ',
      subTxt: '2,4km',
      dist: 3.0,
      reviews: 62,
      rating: 4.0,
      perNight: 60,
      roomSizeTxt: '2 Room - 3 Adults',
      isSelected: false,
      dateTxt:
      '${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 3)))} - ${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 4)))}',
    ),
    HotelListData(
      imagePath: 'assets/images/place.png',
      titleTxt: 'Chung cư quân 11 ',
      subTxt: '2,4km',
      dist: 7.0,
      reviews: 90,
      rating: 4.4,
      perNight: 170,
      isSelected: false,
      roomSizeTxt: '2R - 2A - 2C',
      dateTxt: '${DateFormat("dd MMM").format(DateTime.now())} - ${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 2)))}',
    ),
    HotelListData(
      imagePath: 'assets/images/place.png',
      titleTxt: 'Chung cư quân 11 ',
      subTxt: '2,4km',
      dist: 2.0,
      reviews: 240,
      rating: 4.5,
      isSelected: false,
      perNight: 200,
      roomSizeTxt: '1 Room - 2 Children',
      dateTxt:
      '${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 3)))} - ${DateFormat("dd MMM").format(DateTime.now().add(Duration(days: 5)))}',
    ),
  ];

  static List<HotelListData> popularList = [
    HotelListData(
      imagePath: 'assets/images/popular_1.jpg',
      titleTxt: 'Paris',
    ),
    HotelListData(
      imagePath: 'assets/images/popular_2.jpg',
      titleTxt: 'Spain',
    ),
    HotelListData(
      imagePath: 'assets/images/popular_3.jpg',
      titleTxt: 'Vernazza',
    ),
    HotelListData(
      imagePath: 'assets/images/popular_4.jpg',
      titleTxt: 'London',
    ),
    HotelListData(
      imagePath: 'assets/images/popular_5.jpg',
      titleTxt: 'Venice',
    ),
    HotelListData(
      imagePath: 'assets/images/popular_6.jpg',
      titleTxt: 'Diamond Head',
    ),
  ];

  static List<HotelListData> reviewsList = [
    HotelListData(
      imagePath: 'assets/images/avatar1.jpg',
      titleTxt: 'Alexia Jane',
      subTxt: 'This is located in a great spot close to shops and bars, very quiet location',
      rating: 8.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
    HotelListData(
      imagePath: 'assets/images/avatar3.jpg',
      titleTxt: 'Jacky Depp',
      subTxt: 'Good staff, very comfortable bed, very quiet location, place could do with an update',
      rating: 8.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
    HotelListData(
      imagePath: 'assets/images/avatar5.jpg',
      titleTxt: 'Alex Carl',
      subTxt: 'This is located in a great spot close to shops and bars, very quiet location',
      rating: 6.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
    HotelListData(
      imagePath: 'assets/images/avatar2.jpg',
      titleTxt: 'May June',
      subTxt: 'Good staff, very comfortable bed, very quiet location, place could do with an update',
      rating: 9.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
    HotelListData(
      imagePath: 'assets/images/avatar4.jpg',
      titleTxt: 'Lesley Rivas',
      subTxt: 'This is located in a great spot close to shops and bars, very quiet location',
      rating: 8.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
    HotelListData(
      imagePath: 'assets/images/avatar6.jpg',
      titleTxt: 'Carlos Lasmar',
      subTxt: 'Good staff, very comfortable bed, very quiet location, place could do with an update',
      rating: 7.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
    HotelListData(
      imagePath: 'assets/images/avatar7.jpg',
      titleTxt: 'Oliver Smith',
      subTxt: 'This is located in a great spot close to shops and bars, very quiet location',
      rating: 9.0,
      dateTxt: 'Last update 21 May, 2019',
    ),
  ];

  static List<HotelListData> romeList = [
    HotelListData(
      imagePath: 'assets/images/room_1.jpg assets/images/room_2.jpg assets/images/room_3.jpg',
      titleTxt: 'Deluxe Room',
      perNight: 180,
      dateTxt: 'Sleeps 3 people',
    ),
    HotelListData(
      imagePath: 'assets/images/room_4.jpg assets/images/room_5.jpg assets/images/room_6.jpg',
      titleTxt: 'Premium Room',
      perNight: 200,
      dateTxt: 'Sleeps 3 people + 2 children',
    ),
    HotelListData(
      imagePath: 'assets/images/room_7.jpg assets/images/room_8.jpg assets/images/room_9.jpg',
      titleTxt: 'Queen Room',
      perNight: 240,
      dateTxt: 'Sleeps 4 people + 4 children',
    ),
    HotelListData(
      imagePath: 'assets/images/room_10.jpg assets/images/room_11.jpg assets/images/room_12.jpg',
      titleTxt: 'King Room',
      perNight: 240,
      dateTxt: 'Sleeps 4 people + 4 children',
    ),
    HotelListData(
      imagePath: 'assets/images/room_11.jpg assets/images/room_1.jpg assets/images/room_2.jpg',
      titleTxt: 'Hollywood Twin Room',
      perNight: 260,
      dateTxt: 'Sleeps 4 people + 4 children',
    ),
  ];

  static List<HotelListData> hotelTypeList = [
    HotelListData(
      imagePath: 'assets/images/hotel_Type_1.jpg',
      titleTxt: 'Hotels',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_2.jpg',
      titleTxt: 'Backpacker',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_3.jpg',
      titleTxt: 'Resort',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_4.jpg',
      titleTxt: 'Villa',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_5.jpg',
      titleTxt: 'Apartment',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_6.jpg',
      titleTxt: 'Guest house',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_7.jpg',
      titleTxt: 'Motel',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_8.jpg',
      titleTxt: 'Accommodation',
      isSelected: false,
    ),
    HotelListData(
      imagePath: 'assets/images/hotel_Type_9.jpg',
      titleTxt: 'Bed & breakfast',
      isSelected: false,
    ),
  ];
  static List<HotelListData> lastsSearchesList = [
    HotelListData(
      imagePath: 'assets/images/popular_4.jpg',
      titleTxt: 'London',
      subTxt: '1 Room - 2 Adults',
      dateTxt: '12 - 22 Dec',
    ),
    HotelListData(
      imagePath: 'assets/images/popular_1.jpg',
      titleTxt: 'Paris',
      subTxt: '2 Room - 4 Adults',
      dateTxt: '12 - 24 Sep',
    ),
    HotelListData(
      imagePath: 'assets/images/city_3.jpg',
      titleTxt: 'New York',
      subTxt: '1 Room - 3 Adults',
      dateTxt: '20 - 22 Sep',
    ),
    HotelListData(
      imagePath: 'assets/images/city_4.jpg',
      titleTxt: 'Tokyo',
      subTxt: '1 Room - 2 Adults',
      dateTxt: '12 - 22 Nov',
    ),
    HotelListData(
      imagePath: 'assets/images/city_5.jpg',
      titleTxt: 'Shanghai',
      subTxt: '2 Room - 4 Adults',
      dateTxt: '10 - 15 Dec',
    ),
    HotelListData(
      imagePath: 'assets/images/city_6.jpg',
      titleTxt: 'Moscow',
      subTxt: '5 Room - 10 Adults',
      dateTxt: '12 - 14 Dec',
    ),
  ];
}
