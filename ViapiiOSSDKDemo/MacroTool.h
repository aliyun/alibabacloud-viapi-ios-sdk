//
//  MacroTool.h
//  ViapiiOSSDKDemo
//
//  Created by wclin on 2021/5/21.
//

#ifndef MacroTool_h
#define MacroTool_h

#ifdef DEBUG
#define viLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define viLog(... )
#endif

#define kwidth     self.view.frame.size.width
#define kheight   self.view.frame.size.height


#endif /* MacroTool_h */
