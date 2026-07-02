import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() =>
      _AddressPageState();
}

class _AddressPageState
    extends State<AddressPage> {

  bool loading = true;

  int userId = 0;

  List addresses = [];

  final Color primaryColor =
  const Color(0xFFEF4138);

  @override
  void initState() {
    super.initState();

    getUser();
  }

  Future<void> getUser() async {

    final prefs =
    await SharedPreferences.getInstance();

    userId =
        prefs.getInt("user_id") ?? 0;

    loadAddress();
  }

  Future<void> loadAddress() async {

    var data =
    await ApiService.getDefaultAddress(
      userId,
    );

    addresses = [];

    if (data["status"] == true &&
        data["address"] != null) {

      addresses.add(
        data["address"],
      );
    }

    setState(() {
      loading = false;
    });
  }

  void addAddressSheet() {

    final nameController =
    TextEditingController();

    final mobileController =
    TextEditingController();

    final addressController =
    TextEditingController();

    final cityController =
    TextEditingController();

    final stateController =
    TextEditingController();

    final pincodeController =
    TextEditingController();

    double latitude=0;

    double longitude=0;

    bool fetching=false;

    String errorMessage = '';

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
      Colors.transparent,

      builder: (_) {

        return StatefulBuilder(
          builder: (_, setStateSheet) {
            Future<void> getLocation()
            async{

              setStateSheet((){

                fetching=true;

              });

              try{

                LocationPermission permission=

                await Geolocator
                    .checkPermission();

                if(
                permission==
                    LocationPermission.denied
                ){

                  permission=

                  await Geolocator
                      .requestPermission();

                }

                Position pos=

                await Geolocator
                    .getCurrentPosition(

                  desiredAccuracy:
                  LocationAccuracy.high,

                );

                latitude=
                    pos.latitude;

                longitude=
                    pos.longitude;

                List<Placemark>
                places=

                await placemarkFromCoordinates(

                  latitude,

                  longitude,

                );

                if(
                places.isNotEmpty
                ){

                  cityController.text=

                      places.first
                          .locality

                          ??

                          "";

                  stateController.text=

                      places.first
                          .administrativeArea

                          ??

                          "";

                  pincodeController.text=

                      places.first
                          .postalCode

                          ??

                          "";

                }

              }catch(e){

                setStateSheet((){
                  errorMessage = e.toString();
                });

              }

              setStateSheet((){

                fetching=false;

              });

            }
            return Container(
              padding:
              EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(
                  context,
                ).viewInsets.bottom +
                    20,
              ),

              decoration:
              const BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.vertical(
                  top:
                  Radius.circular(
                    30,
                  ),
                ),
              ),

              child:
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    Center(
                      child: Container(
                        height: 5,
                        width: 70,

                        decoration:
                        BoxDecoration(
                          color: Colors
                              .grey
                              .shade300,

                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Text(
                      "Add New Address",

                      style:
                      GoogleFonts.poppins(
                        fontSize: 20,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    if (errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),

                        decoration: BoxDecoration(
                          color: const Color(0x20DC2626),
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Text(
                          errorMessage,

                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 6,
                    ),

                    field(
                      nameController,
                      "Full Name",
                    ),

                    field(
                      mobileController,
                      "Mobile Number",
                    ),

                    field(
                      addressController,
                      "Full Address",
                      max: 3,
                    ),

                    field(
                      cityController,
                      "City",
                    ),

                    field(
                      stateController,
                      "State",
                    ),

                    field(
                      pincodeController,
                      "Pincode",
                    ),

                    const SizedBox(
                      height:12,
                    ),

                    SizedBox(

                      width:
                      double.infinity,

                      height:
                      56,

                      child:

                      OutlinedButton.icon(

                        onPressed:

                        fetching

                            ?

                        null

                            :

                        getLocation,

                        icon:

                        fetching

                            ?

                        const SizedBox(

                          height:18,

                          width:18,

                          child:

                          CircularProgressIndicator(),

                        )

                            :

                        Icon(

                          Icons.my_location,

                          color:
                          primaryColor,

                        ),

                        label:

                        Text(

                          fetching

                              ?

                          "Fetching Location..."

                              :

                          "Use Current Location",

                        ),

                      ),

                    ),

                    const SizedBox(
                      height:20,
                    ),
                    SizedBox(
                      width:
                      double.infinity,

                      height: 56,

                      child:
                      ElevatedButton(

                        onPressed:
                            () async {

                          var data =
                          await ApiService
                              .saveAddress(

                            userId,

                            nameController.text,

                            mobileController.text,

                            addressController.text,

                            cityController.text,

                            stateController.text,

                            pincodeController.text,

                            latitude,

                            longitude,

                          );
                          if (data[
                          "status"] ==
                              true) {

                            Navigator.pop(
                              context,
                            );

                            loadAddress();

                          } else {

                            setStateSheet(() {
                              errorMessage =
                                  data["message"] ??
                                  "Failed to save address";
                            });
                          }
                        },

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          primaryColor,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
                        ),

                        child: Text(
                          "Save Address",

                          style:
                          GoogleFonts.poppins(
                            color:
                            Colors.white,

                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF6F7F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,

        title: Text(
          "Saved Addresses",

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Colors.black87,
          ),
        ),

        centerTitle: true,
      ),

      floatingActionButton:
      addresses.isNotEmpty

          ? FloatingActionButton.extended(

        backgroundColor:
        primaryColor,

        onPressed: () {

          addAddressSheet();
        },

        label: Text(
          "Add Address",

          style:
          GoogleFonts.poppins(
            color: Colors.white,

            fontWeight:
            FontWeight.w600,
          ),
        ),

        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      )

          : null,

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : addresses.isEmpty

          ? Center(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              // 🔥 LOTTIE
              Lottie.asset(
                "assets/images/nodata.json",
                height: 220,
              ),

              const SizedBox(height: 20),

              Text(
                "No Saved Address",

                textAlign:
                TextAlign.center,

                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w700,

                  color:
                  const Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "You haven't added any address yet.\nAdd a delivery address to continue shopping.",

                textAlign:
                TextAlign.center,

                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                height: 54,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: ElevatedButton(

                  onPressed: () {

                    addAddressSheet();
                  },

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryColor,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),

                    elevation: 0,
                  ),

                  child: Text(
                    "Add New Address",

                    style: GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.w700,

                      fontSize: 14,

                      color:
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )

          : RefreshIndicator(

        onRefresh: () async {

          loadAddress();
        },

        child: ListView.builder(

          padding:
          const EdgeInsets.all(16),

          itemCount:
          addresses.length,

          itemBuilder:
              (_, index) {

            final item =
            addresses[index];

            return Container(

              margin:
              const EdgeInsets.only(
                bottom: 16,
              ),

              padding:
              const EdgeInsets.all(
                20,
              ),

              decoration:
              BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(
                  22,
                ),

                border: Border.all(
                  color: const Color(0xFFF0F0F0),
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                    Colors.black
                        .withOpacity(
                      0.05,
                    ),

                    blurRadius: 18,

                    offset:
                    const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Container(
                        height: 46,
                        width: 46,

                        decoration:
                        BoxDecoration(
                          color:
                          primaryColor
                              .withOpacity(
                            0.12,
                          ),

                          shape:
                          BoxShape.circle,
                        ),

                        child: Icon(
                          Icons.location_on,

                          color:
                          primaryColor,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(
                              item[
                              "full_name"],

                              style:
                              GoogleFonts.poppins(
                                fontWeight:
                                FontWeight
                                    .w700,

                                fontSize:
                                16,
                              ),
                            ),

                            const SizedBox(
                              height:
                              4,
                            ),

                            Text(
                              item[
                              "mobile"],

                              style:
                              GoogleFonts.poppins(
                                color:
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          12,

                          vertical:
                          6,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.green
                              .withOpacity(
                            0.12,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                        ),

                        child: Text(
                          "Default",

                          style:
                          GoogleFonts.poppins(
                            color:
                            Colors.green,

                            fontSize:
                            12,

                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "${item["address"]}, ${item["city"]}, ${item["state"]} - ${item["pincode"]}",

                    style:
                    GoogleFonts.poppins(
                      height: 1.7,

                      color:
                      Colors.grey
                          .shade700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget field(
      TextEditingController controller,
      String hint, {
        int max = 1,
      }) {

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),

      child: TextField(
        controller: controller,

        maxLines: max,

        decoration: InputDecoration(
          hintText: hint,

          filled: true,

          fillColor:
          const Color(0xFFF7F7F7),

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              18,
            ),

            borderSide:
            BorderSide.none,
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              18,
            ),

            borderSide:
            BorderSide.none,
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              18,
            ),

            borderSide:
            BorderSide(
              color: primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}