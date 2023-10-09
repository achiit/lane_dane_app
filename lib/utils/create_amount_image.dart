import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:lane_dane/models/transactions.dart';
import 'package:lane_dane/utils/colors.dart';

Future<img.Image> createBlankFilledImage(
    {Color backgroundColor = Colors.white}) async {
  img.Command command = (img.Command()
    ..createImage(width: 1080, height: 480)
    ..fill(
        color: img.ColorRgb8(
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    )));
  await command.execute();
  img.Image? image = command.outputImage;
  if (image == null) {
    throw 'failed to create image';
  }

  return image;
}

Future<img.Image> addMainContentToImage({
  required img.Image image,
  required String text,
  required Color textColor,
  bool center = false,
}) async {
  int contentPositionX;
  int contentPositionY;
  if (center) {
    contentPositionX = image.width ~/ 2.3;
    contentPositionY = image.height ~/ 2.3;
  } else {
    contentPositionX = image.width ~/ 2.3;
    contentPositionY = image.height ~/ 3;
  }

  img.Command command = img.Command();
  command.image(image);
  command.drawString(text,
      font: await _getAssetFont('assets/font/Roboto-Bold-64.ttf.zip'),
      x: contentPositionX,
      y: contentPositionY,
      color: img.ColorRgb8(
        textColor.red,
        textColor.green,
        textColor.blue,
      ));
  await command.execute();

  img.Image? imageWithMainContent = await command.getImage();

  return imageWithMainContent!;
}

Future<img.Image> addTitleToImage({
  required img.Image image,
  required String text,
  required Color textColor,
}) async {
  int contentPositionX = image.width ~/ 2.3;
  int contentPositionY = image.height ~/ 2;

  img.Command command = img.Command();
  command.image(image);
  command.drawString(text,
      font: await _getAssetFont('assets/font/Roboto-Medium-52.ttf.zip'),
      x: contentPositionX,
      y: contentPositionY,
      color: img.ColorRgb8(
        textColor.red,
        textColor.green,
        textColor.blue,
      ));
  await command.execute();

  img.Image? imageWithMainContent = await command.getImage();

  return imageWithMainContent!;
}

Future<img.Image> addSubtitleToImage({
  required img.Image image,
  required String text,
  required Color textColor,
}) async {
  int contentPositionX = image.width ~/ 2.3;
  int contentPositionY = image.height ~/ 1.4;

  img.Command command = img.Command();
  command.image(image);
  command.drawString(text,
      font: await _getAssetFont('assets/font/Roboto-Medium-48.ttf.zip'),
      x: contentPositionX,
      y: contentPositionY,
      color: img.ColorRgb8(
        textColor.red,
        textColor.green,
        textColor.blue,
      ));
  await command.execute();

  img.Image? imageWithMainContent = await command.getImage();

  return imageWithMainContent!;
}

Future<img.Image> addStickerToImage({
  required img.Image image,
}) async {
  img.Image src = await _loadAsset('assets/logo/lane_dane_logo_green.png');

  int height = image.height;
  int width = image.width;

  int stickerHeight = (height * 0.7).toInt();
  int stickerWidth = (width * 0.3).toInt();

  int offsetY = (height ~/ 2) - (src.height ~/ 2);
  int offsetX = (10);

  img.Image inlaidImage = img.compositeImage(
    image,
    src,
    srcH: src.height,
    srcW: src.width,
    srcX: 0,
    srcY: 0,
    dstH: src.height,
    dstW: src.width,
    dstX: 0,
    dstY: offsetY,
  );
  return inlaidImage;
}

Future<img.Image> addTransactionTypeIcon({
  required TransactionType type,
  required img.Image image,
}) async {
  int imageHeight = image.height;
  int imageWidth = image.width;

  int circleOffsetX = ((imageWidth ~/ 3) - 40) ~/ 2 + 80;
  int circleOffsetY = imageHeight ~/ 2;

  int circleRadius = ((imageWidth ~/ 3) - 40) ~/ 2;

  int arrowX1 = circleOffsetX - (circleRadius - 50) ~/ 2;
  int arrowY1 = circleOffsetY + (circleRadius - 50) ~/ 2;
  int arrowX2 = circleOffsetX + (circleRadius - 50) ~/ 2;
  int arrowY2 = circleOffsetY - (circleRadius - 50) ~/ 2;

  int arrowHeadLength = 70;
  int arrowStroke = 8;

  img.ColorRgba8 circleColor;
  img.ColorRgba8 arrowColor;
  int arrowIntersectionX;
  int arrowIntersectionY;

  int arrowLeftX;
  int arrowLeftY;

  int arrowRightX;
  int arrowRightY;

  if (type == TransactionType.Lane) {
    circleColor = img.ColorRgba8(
      laneColor.red,
      laneColor.green,
      laneColor.blue,
      255 ~/ 5,
    );
    arrowColor = img.ColorRgba8(
      laneColor.red,
      laneColor.green,
      laneColor.blue,
      255,
    );
    arrowIntersectionX = arrowX1;
    arrowIntersectionY = arrowY1;

    arrowLeftX = arrowIntersectionX;
    arrowLeftY = arrowIntersectionY - arrowHeadLength;

    arrowRightX = arrowIntersectionX + arrowHeadLength;
    arrowRightY = arrowIntersectionY;
  } else {
    circleColor = img.ColorRgba8(
      daneColor.red,
      daneColor.green,
      daneColor.blue,
      255 ~/ 5,
    );
    arrowColor = img.ColorRgba8(
      daneColor.red,
      daneColor.green,
      daneColor.blue,
      255,
    );
    arrowIntersectionX = arrowX2;
    arrowIntersectionY = arrowY2;

    arrowLeftX = arrowIntersectionX - arrowHeadLength;
    arrowLeftY = arrowIntersectionY;

    arrowRightX = arrowIntersectionX;
    arrowRightY = arrowIntersectionY + arrowHeadLength;
  }

  img.Command command = img.Command();
  command.image(image);

  command.fillCircle(
    color: circleColor,
    radius: circleRadius,
    x: circleOffsetX,
    y: circleOffsetY,
  );

  command.drawLine(
    x1: arrowX1,
    y1: arrowY1,
    x2: arrowX2,
    y2: arrowY2,
    color: arrowColor,
    thickness: arrowStroke,
  );

  command.drawLine(
    x1: arrowIntersectionX,
    y1: arrowIntersectionY,
    x2: arrowRightX,
    y2: arrowRightY,
    color: arrowColor,
    thickness: arrowStroke,
  );
  command.drawLine(
    x1: arrowIntersectionX,
    y1: arrowIntersectionY,
    x2: arrowLeftX,
    y2: arrowLeftY,
    color: arrowColor,
    thickness: arrowStroke,
  );

  await command.execute();

  img.Image? imageWithIcon = await command.getImage();

  return imageWithIcon!;
}

Future<img.BitmapFont> _getAssetFont(String path) async {
  ByteData fontFilePath = await rootBundle.load(
    path,
  );

  final img.BitmapFont font = img.BitmapFont.fromZip(
    fontFilePath.buffer.asUint8List(),
  );

  return font;
}

Future<img.Image> _loadAsset(String path) async {
  ByteData binFileData = await rootBundle.load(path);
  ui.ImmutableBuffer buffer =
      await ui.ImmutableBuffer.fromUint8List(binFileData.buffer.asUint8List());

  ui.ImageDescriptor imageDescriptor = await ui.ImageDescriptor.encoded(buffer);

  ui.Codec codec = await imageDescriptor.instantiateCodec(
    targetHeight: imageDescriptor.height,
    targetWidth: imageDescriptor.width,
  );

  ui.FrameInfo frameInfo = await codec.getNextFrame();

  ui.Image nativeImage = frameInfo.image;

  ByteData? imageData = (await nativeImage.toByteData());

  img.Image image = img.Image.fromBytes(
    width: imageDescriptor.width,
    height: imageDescriptor.height,
    bytes: imageData!.buffer,
    numChannels: 4,
  );

  return image;
}
