import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'api_service.dart';
import 'constants.dart';
import 'post.dart';

class PostsPage extends StatefulWidget {

  const PostsPage({
    super.key,
  });

  @override
  State<PostsPage> createState() =>
      _PostsPageState();
}

class _PostsPageState
    extends State<PostsPage>{
  final Map<int,VideoPlayerController>
  videos={};
  bool loading=true;

  List posts=[];

  final red=
  const Color(
    0xffe53935,
  );

  @override
  void initState(){

    super.initState();

    loadPosts();

  }

  Future loadPosts() async {

    loading=true;

    setState((){});

    posts=
    await ApiService
        .getPosts();

    loading=false;

    setState((){});

  }
  Future<void>
  toggleVideo(
      int index,
      String file,
      ) async {

    if(
    !videos.containsKey(
      index,
    )
    ){

      final controller=

      VideoPlayerController
          .networkUrl(

        Uri.parse(

          AppConstants.imageUrl+
              file,

        ),

      );

      await controller
          .initialize();

      videos[
      index
      ]
      =
          controller;

    }

    if(

    videos[
    index
    ]!
        .value
        .isPlaying

    ){

      videos[
      index
      ]!
          .pause();

    }else{

      videos[
      index
      ]!
          .play();

    }

    setState((){});

  }
  @override
  void dispose(){

    for(

    final controller

    in

    videos.values

    ){

      controller.pause();

      controller.dispose();

    }

    videos.clear();

    super.dispose();

  }
  @override
  Widget build(
      BuildContext context,
      ){

    return Scaffold(

      backgroundColor:
      const Color(
        0xfffafafa,
      ),

      appBar:

      AppBar(

        elevation:0,

        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        title:

        const Text(

          "Social Feed",

          style:
          TextStyle(
            color:
            Colors.black,
            fontWeight:
            FontWeight.w700,
          ),

        ),

        centerTitle:true,

      ),

      body:

      loading

          ?

      Center(

        child:

        CircularProgressIndicator(
          color:red,
        ),

      )

          :

      RefreshIndicator(

        color:red,

        onRefresh:
        loadPosts,

        child:

        posts.isEmpty

            ?

        const Center(

          child:

          Text(
            "No Posts Yet",
          ),

        )

            :

        ListView.builder(

          padding:
          const EdgeInsets.only(
            top:10,
            bottom:20,
          ),

          itemCount:
          posts.length,

          itemBuilder:
              (
              context,
              index,
              ){

            var p=
            posts[index];

            return InkWell(

              onTap:() async {

// stop all playing videos

                for(

                final controller

                in

                videos.values

                ){

                  if(
                  controller
                      .value
                      .isPlaying
                  ){

                    await controller
                        .pause();

                  }

                }

                if(
                !mounted
                )return;

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:
                        (_)=>PostPage(

                      postId:

                      int.parse(
                        p["id"]
                            .toString(),
                      ),

                    ),

                  ),

                );

              },

              child:

              Container(

                margin:
                const EdgeInsets.only(

                  left:14,

                  right:14,

                  bottom:18,

                ),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    26,
                  ),

                  boxShadow:[

                    BoxShadow(

                      blurRadius:
                      20,

                      offset:
                      const Offset(
                        0,
                        10,
                      ),

                      color:
                      Colors.black
                          .withOpacity(
                        0.05,
                      ),

                    ),

                  ],

                ),

                child:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children:[

                    Padding(

                      padding:
                      const EdgeInsets.all(
                        16,
                      ),

                      child:

                      Row(

                        children:[

                          Container(

                            height:52,
                            width:52,

                            decoration:
                            BoxDecoration(

                              shape:
                              BoxShape.circle,

                              gradient:

                              LinearGradient(

                                colors:[

                                  red,

                                  red
                                      .withOpacity(
                                    0.65,
                                  ),

                                ],

                              ),

                            ),

                            child:

                            const Icon(

                              Icons.store,

                              color:
                              Colors.white,

                            ),

                          ),

                          const SizedBox(
                            width:12,
                          ),

                          Expanded(

                            child:

                            Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children:[

                                Text(

                                  p[
                                  "seller_name"
                                  ] ??
                                      "Seller",

                                  style:
                                  const TextStyle(

                                    fontWeight:
                                    FontWeight.w700,

                                    fontSize:
                                    17,

                                  ),

                                ),

                                const SizedBox(
                                  height:4,
                                ),

                                Text(

                                  "Posted recently",

                                  style:

                                  TextStyle(

                                    color:
                                    Colors.grey
                                        .shade600,

                                    fontSize:
                                    13,

                                  ),

                                ),

                              ],

                            ),

                          ),

                          const Icon(
                            Icons.more_horiz,
                          ),

                        ],

                      ),

                    ),

                    if(
                    p["media"]!=null
                        &&
                        p["media"]!=""
                    )

                      ClipRRect(

                        borderRadius:

                        const BorderRadius.only(

                          topLeft:
                          Radius.circular(
                            12,
                          ),

                          topRight:
                          Radius.circular(
                            12,
                          ),

                        ),

                        child:

                        p["type"]
                            ==
                            "video"

                            ?

                        GestureDetector(

                          onTap:(){

                            toggleVideo(

                              index,

                              p["media"],

                            );

                          },

                          child:

                          Stack(

                            alignment:
                            Alignment.center,

                            children:[

                              videos[
                              index
                              ]
                                  !=
                                  null

                                  &&

                                  videos[
                                  index
                                  ]!
                                      .value
                                      .isInitialized

                                  ?

                              AspectRatio(

                                aspectRatio:

                                videos[
                                index
                                ]!
                                    .value
                                    .aspectRatio,

                                child:

                                VideoPlayer(

                                  videos[
                                  index
                                  ]!,

                                ),

                              )

                                  :

                              Container(

                                height:
                                280,

                                color:
                                Colors.black,

                              ),

                              AnimatedOpacity(

                                duration:
                                const Duration(
                                  milliseconds:200,
                                ),

                                opacity:

                                videos[
                                index
                                ]
                                    ==
                                    null

                                    ||

                                    !

                                    videos[
                                    index
                                    ]!
                                        .value
                                        .isPlaying

                                    ?

                                1

                                    :

                                0,

                                child:

                                Container(

                                  height:
                                  90,

                                  width:
                                  90,

                                  decoration:

                                  BoxDecoration(

                                    color:
                                    Colors.black54,

                                    shape:
                                    BoxShape.circle,

                                  ),

                                  child:

                                  const Icon(

                                    Icons.play_arrow,

                                    color:
                                    Colors.white,

                                    size:
                                    54,

                                  ),

                                ),

                              ),

                            ],

                          ),

                        )

                            :

                        Image.network(

                          AppConstants.imageUrl+

                              p["media"],

                          height:
                          280,

                          width:
                          double.infinity,

                          fit:
                          BoxFit.contain,

                        ),

                      ),
                    if(
                    (
                        p[
                        "text_content"
                        ] ??
                            ""
                    )
                        .toString()
                        .isNotEmpty
                    )

                      Padding(

                        padding:
                        const EdgeInsets.fromLTRB(
                          18,
                          16,
                          18,
                          12,
                        ),

                        child:

                        Text(

                          p[
                          "text_content"
                          ],

                          style:

                          TextStyle(

                            height:
                            1.5,

                            fontSize:
                            15,

                            color:
                            Colors.grey
                                .shade800,

                          ),

                        ),

                      ),

                    Padding(

                      padding:
                      const EdgeInsets.only(

                        left:18,

                        right:18,

                        bottom:18,

                      ),

                      child:

                      Row(

                        children:[

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:
                              14,

                              vertical:
                              10,

                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              red
                                  .withOpacity(
                                0.08,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                100,
                              ),

                            ),

                            child:

                            Row(

                              children:[

                                Icon(

                                  Icons.favorite,

                                  size:
                                  18,

                                  color:
                                  red,

                                ),

                                const SizedBox(
                                  width:8,
                                ),

                                Text(

                                  "${int.tryParse(
                                    p["likes"]
                                        .toString(),
                                  )
                                      ??
                                      0}",

                                  style:
                                  TextStyle(
                                    color:red,
                                  ),

                                ),

                              ],

                            ),

                          ),

                          const SizedBox(
                            width:12,
                          ),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:
                              14,

                              vertical:
                              10,

                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              Colors.grey
                                  .shade100,

                              borderRadius:
                              BorderRadius.circular(
                                100,
                              ),

                            ),

                            child:

                            Row(

                              children:[

                                Icon(

                                  Icons.mode_comment_outlined,

                                  size:
                                  18,

                                  color:
                                  Colors.grey
                                      .shade700,

                                ),

                                const SizedBox(
                                  width:8,
                                ),

                                Text(
                                  "${p["comments"]}",
                                ),

                              ],

                            ),

                          ),

                          const Spacer(),

                          Icon(

                            Icons.arrow_forward,

                            color:
                            red,

                          ),

                        ],

                      ),

                    ),

                  ],

                ),

              ),

            );

          },

        ),

      ),

    );

  }
}
