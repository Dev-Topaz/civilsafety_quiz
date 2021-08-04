import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class QuizListCard extends StatefulWidget {

  final String? title;
  final String? quizType;
  final String? description;
  final int? score;
  final int? passingScore;
  final String? downloaded;
  final String? examIcon;
  final bool? isOnline;
  final void Function()? startPressed;
  final void Function()? downloadPressed;
  final void Function()? deletePressed;

  QuizListCard({Key? key,
    this.title,
    this.description,
    this.quizType,
    this.score,
    this.passingScore,
    this.downloaded,
    this.isOnline,
    this.startPressed,
    this.deletePressed,
    this.downloadPressed,
    this.examIcon,
  }) : super(key: key);

  @override
  _QuizListCardState createState() => _QuizListCardState();
}

class _QuizListCardState extends State<QuizListCard> {

  double height = 65.0;
  bool isExpanded = true;
  Color? color;
  IconData? icon;

  @override
  Widget build(BuildContext context) {

    switch (this.widget.quizType) {
      case 'Pass':
        color = Color(0xFF17A05D);
        icon = Icons.check_circle_rounded;
        break;
      case 'Fail':
        color = Color(0xFFDD4F43);
        icon = Icons.warning;
        break;
      case 'none':
        color = Color(0xFFFFCD43);
        break;
      default:
    }

    double rating = (this.widget.score ?? 0) / this.widget.passingScore! < 1 ? (this.widget.score ?? 0) / this.widget.passingScore! * 5 : 5;

    return Container(
       child: Column(
         children: [
           GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Container(
                padding: EdgeInsets.only(left: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: color,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 4, offset: Offset(3, 3))
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(height: 60,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: this.widget.isOnline! && this.widget.examIcon != '' ? Colors.transparent : color,
                                  backgroundImage: this.widget.isOnline! && this.widget.examIcon != '' ? NetworkImage(this.widget.examIcon!) : null,
                                  child: this.widget.isOnline! && this.widget.examIcon != ''
                                  ? null
                                  :Text(this.widget.title![0].toUpperCase(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 180,
                                        child: Text(this.widget.title!, style: TextStyle(fontSize: 16.0),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // SizedBox(width: 5.0,),
                                      // this.widget.quizType != 'none' ? Icon(Icons.circle_rounded, size: 8.0, color: color,) : SizedBox(width: 0),
                                      // SizedBox(width: 5.0,),
                                      // this.widget.quizType != 'none' ? Text(this.widget.quizType!, style: TextStyle(color: color),) : SizedBox(width: 0,),
                                    ],),
                                    Container(
                                      child: Text('Passing Score: ${this.widget.passingScore}', 
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey),),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: 75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      this.widget.quizType != 'none' ? Icon(Icons.circle_rounded, size: 8.0, color: color,) : SizedBox(width: 0),
                                      SizedBox(width: 5.0,),
                                      this.widget.quizType != 'none' ? Text(this.widget.quizType!, style: TextStyle(color: color),) : SizedBox(width: 0,),
                                    ],
                                  ),
                                  this.widget.quizType != 'none' ? Icon(icon, color: color,) : SizedBox(width: 0,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      !isExpanded
                      ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Divider(thickness: 1, height: 1,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  this.widget.description!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(fontSize: 16),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Text('Score: ' + (this.widget.score ?? 0).toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RatingBar.builder(
                                      initialRating: rating,
                                      ignoreGestures: true,
                                      unratedColor: Colors.grey,
                                      itemSize: 24.0,
                                      allowHalfRating: true,
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceAround,
                              buttonHeight: 52.0,
                              buttonMinWidth: 90.0,
                              children: <Widget>[
                                FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  onPressed: this.widget.startPressed,
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.play_arrow,
                                        color: this.widget.downloaded == 'true' ? Theme.of(context).primaryColor : Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      ),
                                      Text('Start',
                                        style: TextStyle(
                                          color: this.widget.downloaded == 'true' ? Theme.of(context).primaryColor : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  onPressed: this.widget.downloadPressed,
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.download,
                                        color: this.widget.isOnline! && this.widget.downloaded == 'false' ? Theme.of(context).primaryColor : Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      ),
                                      Text('Download',
                                        style: TextStyle(color: this.widget.isOnline! && this.widget.downloaded == 'false' ? Theme.of(context).primaryColor : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  onPressed: this.widget.deletePressed,
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.delete_sweep_sharp,
                                        color: this.widget.isOnline! && this.widget.downloaded == 'false' ? Colors.grey : Theme.of(context).primaryColor,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      ),
                                      Text('Delete',
                                        style: TextStyle(
                                          color: this.widget.isOnline! && this.widget.downloaded == 'false' ? Colors.grey : Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),  
           ),
         ],
       ),
    );
  }
}