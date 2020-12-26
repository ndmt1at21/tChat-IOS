//
// Copyright (c) 2020 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum KeepMedia {

	static let Week		= 1
	static let Month	= 2
	static let Forever	= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum Network {

	static let Manual	= 1
	static let WiFi		= 2
	static let All		= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum MediaType {

	static let Photo	= 1
	static let Video	= 2
	static let Audio	= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum MediaStatus {

	static let Unknown	= 0
	static let Loading	= 1
	static let Manual	= 2
	static let Succeed	= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum AudioStatus {

	static let Stopped	= 1
	static let Playing	= 2
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum App {

	static let DefaultTab			= 0
	static let MaxVideoDuration		= TimeInterval(10)
}
