( function _Procedure_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = require( '../../Tools.s' );
  require( '../l8/Procedure.s' );

  _.include( 'wTesting' );

  // _.include( 'wLogger' );
  // _.include( 'wAppBasic' );
  // _.include( 'wFiles' );

}

var _global = _global_;
var _ = _global_.wTools;
let fileProvider = _testerGlobal_.wTools.fileProvider;
let path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = path.pathDirTempOpen( path.join( __dirname, '../..'  ), 'procedure' );
  self.assetsOriginalSuitePath = path.join( __dirname, '_asset' );

}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/procedure-' ) )
  path.pathDirTempClose( self.suiteTempPath );
}

// --
// test
// --

function timeLimit( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    let t = 25;
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );
    var con = _.time.out( t*1 );
    con.timeLimit( t*6, () => _.time.out( t*3, 'a' ) );
    // _.procedure.terminationBegin();
  }

}

timeLimit.timeOut = 30000;
timeLimit.description =
`
- application does not have to wait for procedures
`

//

function timeLimitWaitingEnough( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for 7 procedure(s)' ), 1 );
    test.identical( _.strCount( op.output, 'procedure::' ), 7 );
    test.identical( _.strCount( op.output, 'Program.js:19' ), 0 );
    test.identical( _.strCount( op.output, 'Program.js:13' ), 6 );
    test.identical( _.strCount( op.output, 'Program.js:16' ), 1 );
    test.identical( _.strCount( op.output, /v0(.|\n|\r)*v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    let t = 1000;
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );
    var con = _.time.out( t*1 );

    console.log( 'v0' );

    con.timeLimit( t*6, () =>
    {
      console.log( 'v2' );
      return _.time.out( t*3, () =>
      {
        console.log( 'v4' );
        return 'a';
      });
    });

    _.time.out( t*2, () =>
    {
      console.log( 'v3' );
      _.procedure.terminationPeriod = 1000;
      _.procedure.terminationBegin();
    });

    console.log( 'v1' );
  }

}

timeLimitWaitingEnough.timeOut = 60000;
timeLimitWaitingEnough.description =
`
- application should wait for procedures because of large time out of async routines
- limit is enough
`

//

function timeLimitWaitingNotEnough( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 1 );
    test.identical( _.strCount( op.output, 'Waiting for 2 procedure(s)' ), 1 );
    test.identical( _.strCount( op.output, 'procedure::' ), 2 );
    test.identical( _.strCount( op.output, 'Program.js:17' ), 1 );
    test.identical( _.strCount( op.output, 'Program.js:14' ), 1 );
    test.identical( _.strCount( op.output, /v0(.|\n|\r)*v1(.|\n|\r)*v2(.|\n|\r)*v3(.|\n|\r)*v4/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 250;
    var con = _.time.out( t*1 );

    console.log( 'v0' );

    con.timeLimit( t*3, () =>
    {
      console.log( 'v2' );
      return _.time.out( t*6, () =>
      {
        console.log( 'v4' );
        return 'a';
      });
    });

    _.time.out( t*2, () =>
    {
      console.log( 'v3' );
      _.procedure.terminationPeriod = t*2;
      _.procedure.terminationBegin();
    });

    console.log( 'v1' );
  }

}

timeLimitWaitingNotEnough.timeOut = 60000;
timeLimitWaitingNotEnough.description =
`
- application should wait for procedures because of large time out of async routines
- limit is not enough
`

//

function timeBegin( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 10;

    _.time.begin( t, () =>
    {
      console.log( 'v2' );
    });

    console.log( 'v1' );

    _.procedure.terminationPeriod = 1000;
    _.procedure.terminationBegin();

    return _.time.out( t*2 );
  }

}

timeBegin.timeOut = 60000;
timeBegin.description =
`
- time begin leave no zombie procedures
`

//

function timeCancelBefore( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'v2' ), 0 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 25;

    let timer = _.time.begin( t*2, () =>
    {
      console.log( 'v2' );
    });

    _.time.out( t, () => _.time.cancel( timer ) );

    console.log( 'v1' );

    _.procedure.terminationPeriod = 1000;
    _.procedure.terminationBegin();

    return _.time.out( t*3 );
  }

}

timeCancelBefore.timeOut = 60000;
timeCancelBefore.description =
`
- time cancel before time out leave no zombie
`

//

function timeCancelAfter( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*v2(.|\n|\r)/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 25;

    let timer = _.time.begin( t, () =>
    {
      console.log( 'v2' );
    });

    _.time.out( t*2, () => _.time.cancel( timer ) );

    console.log( 'v1' );

    _.procedure.terminationPeriod = 1000;
    _.procedure.terminationBegin();

    return _.time.out( t*3 );
  }

}

timeCancelAfter.timeOut = 60000;
timeCancelAfter.description =
`
- time cancel after time out leave no zombie
`

//

function timeOutBug( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../Layer2.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'xxx' ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wProcedure' );
    _.include( 'wConsequence' );
    var t = 100;

    _global_.debugger = true;
    // debugger;
    var con1 = _.time.out( t*2, () => 1 );
    // debugger;

    console.log( 'v1' )
    return _.time.out( t, function()
    {
      console.log( 'v2' )
      con1.take( 2 );
      con1.give( ( err, got ) =>
      {
        console.log( 'v3' )
      });
      con1.give( ( err, got ) =>
      {
        console.log( 'v4' )
      });
    })

    return _.time.out( t*5 );
  }


}

timeOutBug.timeOut = 60000;
timeOutBug.description =
`
- xxx
`

//

function terminationEventsExplicitTermination( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 4 );
    test.identical( _.strCount( op.output, 'procedure::' ), 1 );
    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'terminationBegin1' ), 1 );
    test.identical( _.strCount( op.output, 'timer' ), 1 );
    test.identical( _.strCount( op.output, 'terminationEnd1' ), 1 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*terminationBegin1(.|\n|\r)*timer(.|\n|\r)*terminationEnd1(.|\n|\r)*/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 5000;

    let timer = _.time.begin( t*1, () =>
    {
      console.log( 'timer' );
    });

    console.log( 'v1' );

    _.Procedure.On( 'terminationBegin', () =>
    {
      console.log( 'terminationBegin1' );
    });

    _.Procedure.On( 'terminationEnd', () =>
    {
      console.log( 'terminationEnd1' );
    });

    _.procedure.terminationPeriod = 1000;
    _.procedure.terminationBegin();

  }

}

terminationEventsExplicitTermination.timeOut = 60000;
terminationEventsExplicitTermination.description =
`
- callback of event terminationBegin get called once
- callback of event terminationEnd get called once
`

//

function terminationEventsImplicitTermination( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'terminationBegin1' ), 1 );
    test.identical( _.strCount( op.output, 'timer' ), 1 );
    test.identical( _.strCount( op.output, 'terminationEnd1' ), 1 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*timer(.|\n|\r)*terminationBegin1(.|\n|\r)*terminationEnd1(.|\n|\r)*/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    let t = 5000;

    let timer = _.time.begin( t*1, () =>
    {
      console.log( 'timer' );
    });

    console.log( 'v1' );

    _.Procedure.On( 'terminationBegin', () =>
    {
      console.log( 'terminationBegin1' );
    });

    _.Procedure.On( 'terminationEnd', () =>
    {
      console.log( 'terminationEnd1' );
    });

    // _.procedure.terminationPeriod = 1000;
    // _.procedure.terminationBegin();

  }

}

terminationEventsImplicitTermination.timeOut = 60000;
terminationEventsImplicitTermination.description =
`
- callback of event terminationBegin get called once
- callback of event terminationEnd get called once
`

//

//

function terminationEventsImplicitTerminationWithConsequence( test )
{
  let context = this;
  let visited = [];
  let a = test.assetFor( false );
  let toolsPath = _testerGlobal_.wTools.strEscape( a.path.nativize( a.path.join( __dirname, '../../Tools.s' ) ) );
  let programSourceCode =
`
var toolsPath = '${toolsPath}';
${program.toString()}
program();
`

  /* */

  logger.log( _.strLinesNumber( programSourceCode ) );
  a.fileProvider.fileWrite( a.abs( 'Program.js' ), programSourceCode );
  a.jsNonThrowing({ execPath : a.abs( 'Program.js' ) })
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, 'Waiting for' ), 0 );
    test.identical( _.strCount( op.output, 'procedure::' ), 0 );
    test.identical( _.strCount( op.output, 'v1' ), 1 );
    test.identical( _.strCount( op.output, 'terminationBegin1' ), 1 );
    test.identical( _.strCount( op.output, 'timer' ), 1 );
    test.identical( _.strCount( op.output, 'terminationEnd1' ), 1 );
    test.identical( _.strCount( op.output, 'got:terminationBegin1' ), 1 );
    test.identical( _.strCount( op.output, /v1(.|\n|\r)*timer(.|\n|\r)*terminationBegin1(.|\n|\r)*terminationEnd1(.|\n|\r)*/mg ), 1 );
    return null;
  });

  /* */

  return a.ready;

  function program()
  {
    let _ = require( toolsPath );
    _.include( 'wConsequence' );
    _.include( 'wProcedure' );

    var con = new _.Consequence();
    
    var result = null;
    con.thenGive( ( r ) => 
    { 
      result = r;
      console.log( 'got:', r )
    })

    console.log( 'v1' );

    _.Procedure.On( 'terminationBegin', () =>
    {
      console.log( 'terminationBegin1' );
      con.take( 'terminationBegin1' )
    });

    _.Procedure.On( 'terminationEnd', () =>
    {
      console.log( 'terminationEnd1' );
    });
    
    _.time.out( 5000, () => 
    {
      if( !result )
      throw _.err( 'terminationBegin not executed automaticaly' );
      return null;
    })

  }

}

terminationEventsImplicitTerminationWithConsequence.timeOut = 60000;
terminationEventsImplicitTerminationWithConsequence.description =
`
- callback of event terminationBegin get called once
- callback of event terminationEnd get called once
- callback of consequence get resource
`

// --
// declare
// --

var Self =
{

  name : 'Tools.base.Procedure',
  silencing : 1,
  routineTimeOut : 30000,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    timeAccuracy : 1,
    suiteTempPath : null,
    assetsOriginalSuitePath : null,
    defaultJsPath : null,
  },

  tests :
  {

    timeLimit,
    timeLimitWaitingEnough,
    timeLimitWaitingNotEnough,
    timeBegin,
    timeCancelBefore,
    timeCancelAfter,

    timeOutBug,

    terminationEventsExplicitTermination,
    terminationEventsImplicitTermination,
    terminationEventsImplicitTerminationWithConsequence

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();