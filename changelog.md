**_17.9.44 (current)** 
*2023-Nov-05*
- Famelist.bin Added new line function "***OVERIDE_PVP_SYSTEM**"

**_17.9.43**

- Fixed bug for FREX stm tidier (#228)
  


**example**

- **Big change**: Drop official support for Node 0.8
- Use JSHint to validate code style and fix numerous warnings it flagged up
  ([#65]) Thanks [XhmikosR](https://github.com/XhmikosR)!
- Fix (yet more! gah) global variable leaks ([#99])
- Fix content tight between two `hr`'s disappearing ([#106])
- Use [Grunt](http://gruntjs.com/) to build tailored versions including allowing
  customizing of what dialects are included ([#113] - [Robin Ward](https://github.com/eviltrout))
- Add in a bower.json for easier use in non-node environments ([#184])
- Lots of small other fixes

