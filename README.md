# Curved Carousel

A Flutter package for easy implementation of curved carousel.

![gif](curved_carousel.gif)


### Easy to use


``` dart
CurvedCarousel(
      itemBuilder: (context, i) {
        return Item(img: listItem[i].img, selectionChange: (bool){
          print('onTap:: ${listItem[i].name}')
        }, selected: listItem[i].selected,key: ValueKey(listItem[i].selected),);
      },
      itemCount: listItem.length,
      middleItemScaleRatio: 1.5,
)
```

### Attributes

`itemBuilder` : builder function returns widget of given index \
`itemCount` : total widgets\
`viewPortSize` : how much size a single item will have, the fractional value lies between 0 and 1, 1 means full size\
`curveScale` : it specifies curviness\
`disableInfiniteScrolling` : by default, infinite scrolling is enable, but if you want to disable it make it true\
`scaleMiddleItem` : scales middle item of carousel, by default it is true\
`middleItemScaleRatio` : it is scaling parameter for middle item\
