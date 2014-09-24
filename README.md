COMService
==========

Project Summary:

Target is to provide a windows based service to response with com based signals.
Also it should be possible to send and receive designated signals over both, com and tcp interface.

==========

Core application will be a windows 32 based service which is able to run without user context. it will react to user commands sent over tcp or com interface. tcp client will be also part of this project