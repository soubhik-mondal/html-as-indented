{
  // T = type
  // k = key
  // v = value
  // TAB = "	"
  const indentationSize = 2;
  const indentationType = ' ';

  function T(k, v) {
    this.k = k;
    this.v = v;
  }
  
  function handleStart(lines) {
    return getHtml(generateParseTree(lines), 2);
  }
  
  function handleLine(Indentation, Node) {
    let sum = 0;
    if (Indentation.v.length) {
      for (let index in Indentation.v) {
        if (Indentation.v[index] === indentationType) {
          sum++;
        } else {
          throw new Error(`Invalid indentation`);
        }
      }
      if (indentationType === " " && sum % indentationSize !== 0) {
        throw new Error("Unmatched indentation");
      }
    }
    Node.indentation = sum / indentationSize;
    return Node;
  }

  function handleHtmlNode(tagName, attribute) {
    return {
      tagName: tagName.v,
      attribute: attribute?.v,
      children: [],
      indentation: 0,
    };
  }

  function handleAttributes(Attr1, Attr2) {
    let attrMap = {};
    if (Attr1[0].length) {
      attrMap[Attr1[0]] = Attr1[1];
    } else {
      throw new Error("Attribute list cannot be empty");
    }
    if (Attr2.length) {
      Attr2.forEach((attr) => {
        attrMap[attr[0]] = attr[1] || null;
      });
    }
    return new T("attributes", attrMap);
  }
  
  function generateParseTree(list) {
    let map = {};
    let stack = [];
  
    if (list.length === 0) {
      return null;
    }
  
    if (list.length === 1) {
      return list[0];
    }
  
    map[list[0].indentation] = [list[0]];
    stack.push(list[0].indentation);
  
    for (let index = 1; index < list.length; index++) {
      let item = list[index];
      let top = stack[stack.length - 1];
  
      if (item.indentation === top) {
        map[top].push(item);
      } else if (item.indentation > top) {
        map[item.indentation] = map[top][map[top].length - 1].children;
        map[item.indentation].push(item);
        stack.push(item.indentation);
      } else {
        while (true) {
          map[stack.pop()] = null;
          if (!stack.length) {
            // You cant have 2 then 3 then 1. Who will be 1's parent ?
            throw new Error("Invalid indentation");
          }
          if (stack.length === 1) {
            // You cant have 0 then 1 then 0. Only one root node allowed.
            throw new Error("Invalid indentation");
          }
          let previousTop = stack[stack.length - 1];
          if (item.indentation === previousTop) {
            map[previousTop].push(item);
            break;
          } else if (item.indentation > previousTop) {
            // You cant have 1 then 3 then 2. Who will be 2's parent ?
            throw new Error("Invalid indentation");
          } else {
            continue;
          }
        }
      }
    }
  
    return list[0];
  }
  
  function getHtml(rootNode, indentation = 0, previousIndentation = 0) {
    let attributes = "";
    let space = "\n" + new Array(previousIndentation * indentation + 1).join(" ");
    // (previousIndentation > 0 && indentation > 0 ? '\n' : '') + new Array(previousIndentation + indentation + 1).join(' ');
    if (rootNode.tagName === "text") {
      return `${space}${rootNode.value}`;
    }
    if (rootNode.attributes && Object.keys(rootNode.attributes).length) {
      attributes =
        " " +
        Object.keys(rootNode.attributes)
          .map((attribute) => {
            if (rootNode.attributes[attribute].length) {
              return `${attribute}="${rootNode.attributes[attribute]}"`;
            } else {
              return attribute;
            }
          })
          .join(" ");
    }
    if (rootNode.children.length) {
      return `${space}<${rootNode.tagName}${attributes}>${rootNode.children
        .map((child) => getHtml(child, indentation, previousIndentation + 1))
        .join("")}${space}</${rootNode.tagName}>`;
    } else {
      return `${space}<${rootNode.tagName}${attributes} />`;
    }
  }  
}

START      = _ Lines:(@LINE _)*                                              { return handleStart(Lines); }
LINE       = Indentation:WS Node:(HTMLNODE / TEXT) WS NL                     { return handleLine(Indentation, Node); }
HTMLNODE   = TagName:TAGNAME Attributes:(__ @ATTRIBUTES)?                    { return handleHtmlNode(TagName, Attributes); }
ATTRIBUTES = "(" __ Attr1:ATTRIBUTE Attr2:( __ "," __ @ATTRIBUTE)* __ ")"    { return handleAttributes(Attr1, Attr2); }
TEXT       = "\"" Text:$[^"]* "\""                                           { return { tagName: 'text', value: Text}; }
ATTRIBUTE  = AttrName:ATTRNAME AttrValue:( __ "=" __ "\"" @ATTRVALUE "\"" )? { return [AttrName, AttrValue]; }
TAGNAME    = [a-zA-Z0-9_-]+                                                  { return new T('tag', text()); }
ATTRNAME   = [a-zA-Z0-9_-]*                                                  { return text(); }
ATTRVALUE  = [a-zA-Z0-9\#.@:/ _-]+                                           { return text(); } /* TODO: Does not handle all possible characters */
__         = _ WS                                                            { return new T('__'); }
_          = ([ \t]*[\r\n]+)*                                                { return new T('_'); }
WS         = [ \t]*                                                          { return new T('ws', text()); }
NL         = [\r\n]*                                                         { return new T('eol'); }
