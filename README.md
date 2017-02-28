# PhotoSearcher

PhotoSearcher is an iOS application that will search photos calling the public API from Instagram and Flickr. It doesn't requiere any kind of authentication.

The most interesting files of PhotoSearcher are SessionManager and Service. With the help of these two classes and protocol oriented programming performing web service class is very easy.
The Service file is a protocol, this way any class which implements it can be considered as a web service.
The SessionManager file is a class which will request the web service call using URLSession and it wil use instances of objects which implementes Service protocol.
Also it has the ServiceTracker file which is a class that will print all the logs of the requests.
More detailed information can be found on the header comments of these classes.

The naming convention follows the Apple guidelines so it is very easy to understand what does all the methods and classes of PhotoSearcher.

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