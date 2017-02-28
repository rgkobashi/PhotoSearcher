# PhotoSearcher

**PhotoSearcher** is an iOS application that will search photos calling the public API from Instagram and Flickr. It doesn't requiere any kind of authentication.

The most interesting part of **PhotoSearcher** are the architectures used, _MVVM_ and _POP_.

**PhotoSearcher** is able to search on two different APIs which are Instagram and Flickr. For this there are two model objects _InstagramPhoto_ and _FlickrPhoto_ which both implements the protocol called _Photo_. These models objects have the properties of every photo like title, number of likes, number of comments, etc. Then there is the class _PhotoViewModel_ which is initialized with an object which implements _Photo_ protocol. Also there is _PhotoViewModel_ class which is in charge of downloading the pictures providing public methods wich are called from the ViewControllers.

Other interesting part of **PhotoSearcher** are the files _SessionManager_ and _Service_. _Service_ file is a protocol which has the necessary properties to create a web service such as url, request type, content type, time out, etc.
_SessionManager_ is a class that use objects which implements _Service_ protocol and is the one in charge of making the request using URLSession.
Also there is _ServiceTracker_ file which is a class that will print all the logs of the requests. More detailed information can be found on the header comments of these classes. _SessionManager_, _Service_ and _ServiceTracker_ are designed in such a way can be reused on other projects which requires web services calls, just drag and drop these three files.

This way, using _MVVM_ and _POP_ escalete **PhotoSearcher** is very simple. If more APIs are added just create a class which implements _Service_ protocol with the information of the web service and another class which implements _Photo_ protocol for the model object.

The naming convention follows the Apple guidelines so it is very easy to understand what does all the methods and classes of **PhotoSearcher**.

## Features

* Search history using core data, including CRUD operations
* Images can be saved or shared

## Screenshots

![Screenshot](/screenshots/main.jpg)

## License

```
MIT License

Copyright (c) 2016 Rogelio Martinez Kobashi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```