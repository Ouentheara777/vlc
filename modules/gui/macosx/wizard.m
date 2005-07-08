/*****************************************************************************
 * wizard.h: MacOS X Streaming Wizard
 *****************************************************************************
 * Copyright (C) 2005 VideoLAN (Centrale Réseaux) and its contributors
 * $Id$
 *
 * Authors: Felix K�hne <fkuehne@users.sf.net> 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.
 *****************************************************************************/

 
/*****************************************************************************
 * Note: this code is based upon ../wxwindows/wizard.cpp and 
 *		 ../wxwindows/streamdata.h; both written by Cl�ment Stenac.
 *****************************************************************************/ 

/* TODO:
    - start of the streaming/transcoding
    - some GUI things
    - l10n string fixes (both in OSX and WX) 
	- implementation of correct encap-selection for transcoding
	- fill the playlist-table on t2
	- implement l10n on t8?
	- see FIXME's
*/

 
/*****************************************************************************
 * Preamble
 *****************************************************************************/ 
#import "wizard.h"
#import "intf.h"


/*****************************************************************************
 * VLCWizard implementation
 *****************************************************************************/

@implementation VLCWizard

static VLCWizard *_o_sharedInstance = nil;

+ (VLCWizard *)sharedInstance
{
    return _o_sharedInstance ? _o_sharedInstance : [[self alloc] init];
}

- (id)init 
{
    if (_o_sharedInstance) {
        [self dealloc];
    } else {
        _o_sharedInstance = [super init];
    }
    
    return _o_sharedInstance;
}

- (void)awakeFromNib
{
    /* some minor cleanup */
    [o_t2_tbl_plst setEnabled:NO];
	[o_wizardhelp_window setExcludedFromWindowsMenu:YES];
	o_userSelections = [[NSMutableDictionary alloc] init];
	[o_btn_backward setEnabled:NO];

    /* add audio-bitrates for transcoding */
    NSArray * audioBitratesArray;
    audioBitratesArray = [NSArray arrayWithObjects: @"512", @"256", @"192", @"128", @"64", @"32", @"16", nil ];
    [o_t4_pop_audioBitrate removeAllItems];
    [o_t4_pop_audioBitrate addItemsWithTitles: audioBitratesArray];
    [o_t4_pop_audioBitrate selectItemWithTitle: @"192"];
    
    /* add video-bitrates for transcoding */
    NSArray * videoBitratesArray;
    videoBitratesArray = [NSArray arrayWithObjects: @"3072", @"2048", @"1024", @"768", @"512", @"256", @"192", @"128", @"64", @"32", @"16", nil ];
    [o_t4_pop_videoBitrate removeAllItems];
    [o_t4_pop_videoBitrate addItemsWithTitles: videoBitratesArray];
    [o_t4_pop_videoBitrate selectItemWithTitle: @"1024"];
    
	/* fill 2 global arrays with arrays containing all codec-related information
	 * - one array per codec named by its short name to define the encap-compability, 
	 *	 cmd-names, real names, more info in the order: realName, shortName, 
	 *	 moreInfo, encaps */
	NSArray * o_mp1v;
	NSArray * o_mp2v;
	NSArray * o_mp4v;
	NSArray * o_div1;
	NSArray * o_div2;
	NSArray * o_div3;
	NSArray * o_h263;
	NSArray * o_h264;
	NSArray * o_wmv1;
	NSArray * o_wmv2;
	NSArray * o_mjpg;
	NSArray * o_theo;
	NSArray * o_dummyVid;
	o_mp1v = [NSArray arrayWithObjects: @"MPEG-1 Video", @"mp1v", _NS("MPEG-1 Video codec"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_OGG", @"MUX_RAW", @"NO", @"NO", @"NO", @"NO", nil];
	o_mp2v = [NSArray arrayWithObjects: @"MPEG-2 Video", @"mp2v", _NS("MPEG-2 Video codec"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_OGG", @"MUX_RAW", @"NO", @"NO", @"NO", @"NO", nil];
	o_mp4v = [NSArray arrayWithObjects: @"MPEG-4 Video", @"mp4v", _NS("MPEG-4 Video codec"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_MP4", @"MUX_OGG", @"MUX_RAW", @"NO", @"NO", nil];
	o_div1 = [NSArray arrayWithObjects: @"DIVX 1", @"DIV1", _NS("DivX first version"), @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_div2 = [NSArray arrayWithObjects: @"DIVX 2", @"DIV2", _NS("DivX second version"), @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_div3 = [NSArray arrayWithObjects: @"DIVX 3", @"DIV3", _NS("DivX third version"), @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_h263 = [NSArray arrayWithObjects: @"H 263", @"H263", _NS("H263 is a video codec optimized for videoconference (low rates)"), @"MUX_TS", @"MUX_AVI", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_h264 = [NSArray arrayWithObjects: @"H 264", @"H264", _NS("H264 is a new video codec"), @"MUX_TS", @"MUX_AVI", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_wmv1 = [NSArray arrayWithObjects: @"WMV 1", @"WMV1", _NS("WMV (Windows Media Video) 1"), @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_wmv2 = [NSArray arrayWithObjects: @"WMV 2", @"WMV2", _NS("WMV (Windows Media Video) 2"), @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_mjpg = [NSArray arrayWithObjects: @"MJPEG", @"MJPG", _NS("MJPEG consists of a series of JPEG pictures"), @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_theo = [NSArray arrayWithObjects: @"Theora", @"theo", _NS("Theora is a free general-purpose codec"), @"MUX_TS", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", @"NO", nil];
	o_dummyVid = [NSArray arrayWithObjects: @"Dummy", @"dummy", _NS("Dummy codec (do not transcode)"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_MP4", @"MUX_OGG", @"MUX_WAV", @"MUX_RAW", @"MUX_MOV", nil];
	o_videoCodecs = [[NSArray alloc] initWithObjects: o_mp1v, o_mp2v, o_mp4v, o_div1, o_div2, o_div3, o_h263, o_h264, o_wmv1, o_wmv2, o_mjpg, o_theo, o_dummyVid, nil];
	[o_t4_pop_videoCodec removeAllItems];
	unsigned int x;
	x = 0;
	while (x != [o_videoCodecs count])
	{
		[o_t4_pop_videoCodec addItemWithTitle:[[o_videoCodecs objectAtIndex:x] objectAtIndex:0]];
		x = (x + 1);
	}
	
	NSArray * o_mpga;
	NSArray * o_mp3;
	NSArray * o_mp4a;
	NSArray * o_a52;
	NSArray * o_vorb;
	NSArray * o_flac;
	NSArray * o_spx;
	NSArray * o_s16l;
	NSArray * o_fl32;
	NSArray * o_dummyAud;
	o_mpga = [NSArray arrayWithObjects: @"MPEG Audio", @"mpga", _NS("The standard MPEG audio (1/2) format"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"MUX_RAW", @"-1", @"-1", @"-1", nil];
	o_mp3 = [NSArray arrayWithObjects: @"MP3", @"mp3", _NS("MPEG Audio Layer 3"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"MUX_RAW", @"-1", @"-1", @"-1", nil];
	o_mp4a = [NSArray arrayWithObjects: @"MPEG 4 Audio", @"mp4a", _NS("Audio format for MPEG4"), @"MUX_TS", @"MUX_MP4", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", nil];
	o_a52 = [NSArray arrayWithObjects: @"A/52", @"a52", _NS("DVD audio format"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_OGG", @"MUX_RAW", @"-1", @"-1", @"-1", nil];
	o_vorb = [NSArray arrayWithObjects: @"Vorbis", @"vorb", _NS("Vorbis is a free audio codec"), @"MUX_OGG", @"-1",  @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", nil];
	o_flac = [NSArray arrayWithObjects: @"FLAC", @"flac", _NS("FLAC is a lossless audio codec"), @"MUX_OGG", @"MUX_RAW", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", nil];
	o_spx = [NSArray arrayWithObjects: @"Speex", @"spx", _NS("A free audio codec dedicated to compression of voice"), @"MUX_OGG", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", nil];
	o_s16l = [NSArray arrayWithObjects: @"Uncompressed, integer", @"s16l", _NS("Uncompressed audio samples"), @"MUX_WAV", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", nil];
	o_fl32 = [NSArray arrayWithObjects: @"Uncompressed, floating", @"fl32", _NS("Uncompressed audio samples"), @"MUX_WAV", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", @"-1", nil];
	o_dummyAud = [NSArray arrayWithObjects: @"Dummy", @"dummy", _NS("Dummy codec (do not transcode)"), @"MUX_PS", @"MUX_TS", @"MUX_MPEG", @"MUX_ASF", @"MUX_MP4", @"MUX_OGG", @"MUX_RAW", @"MUX_MOV", @"MUX_WAV", nil];
	o_audioCodecs = [[NSArray alloc] initWithObjects: o_mpga, o_mp3, o_mp4a, o_a52, o_vorb, o_flac, o_spx, o_s16l, o_fl32, o_dummyAud, nil];
	[o_t4_pop_audioCodec removeAllItems];
	x = 0;
	while (x != [o_audioCodecs count])
	{
		[o_t4_pop_audioCodec addItemWithTitle:[[o_audioCodecs objectAtIndex:x] objectAtIndex:0]];
		x = (x + 1);
	}
}

- (void)showWizard
{
    /* just present the window to the user */
    [o_tab_pageHolder selectFirstTabViewItem:self];
    
	[self resetWizard];
	
    [o_wizard_window center];
    [o_wizard_window displayIfNeeded];
    [o_wizard_window makeKeyAndOrderFront:nil];
}

- (void)resetWizard
{
	/* reset the wizard-window to its default values */
	
	[o_userSelections removeAllObjects];
	[o_t1_matrix_strmgOrTrnscd selectCellAtRow:0 column:0];
	[[o_t1_matrix_strmgOrTrnscd cellAtRow:1 column:0] setState: NSOffState];
	[o_btn_forward setTitle: [_NS("Next") stringByAppendingString:@" >"]];
	
	/* "Input" */
	[o_t2_fld_pathToNewStrm setStringValue: @""];
	[o_t2_ckb_enblPartExtrct setState: NSOffState];
	[self t2_enableExtract:nil];
	[o_t2_matrix_inputSourceType selectCellAtRow:0 column:0];
	[[o_t2_matrix_inputSourceType cellAtRow:1 column:0] setState: NSOffState];
	/* FIXME: we need to refresh the playlist-table as well */
	[o_t2_tbl_plst setEnabled:NO];
	[o_t2_fld_pathToNewStrm setEnabled:YES];
	[o_t2_btn_chooseFile setEnabled:YES];
	
	/* "Streaming 1" */
	[o_t3_fld_address setStringValue: @""];
	[o_t3_matrix_stmgMhd selectCellAtRow:0 column:0];
	[[o_t3_matrix_stmgMhd cellAtRow:1 column:1] setState: NSOffState];
	[[o_t3_matrix_stmgMhd cellAtRow:1 column:2] setState: NSOffState];
	
	/* "Transcode 1" */
	[o_t4_ckb_audio setState: NSOffState];
	[o_t4_ckb_video setState: NSOffState];
	[self t4_enblVidTrnscd:nil];
	[self t4_enblAudTrnscd:nil];
	
	/* "Streaming 2" */
	[o_t6_fld_ttl setStringValue: @"1"];
	[o_t6_ckb_sap setState: NSOffState];
	[self t6_enblSapAnnce:nil];
	
	/* "Transcode 2" */
	[o_t7_fld_filePath setStringValue: @""];
}

- (void)initStrings
{
    /* localise all strings to the users lang */
    /* method is called from intf.m (in method openWizard) */
    
    /* general items */
    [o_btn_backward setTitle: [@"< " stringByAppendingString: _NS("Back")]];
    [o_btn_cancel setTitle: _NS("Cancel")];
    [o_btn_forward setTitle: [_NS("Next") stringByAppendingString:@" >"]];
    [o_wizard_window setTitle: _NS("Streaming/Transcoding Wizard")];
    
    /* page one ("Hello") */
    [o_t1_txt_title setStringValue: _NS("Streaming/Transcoding Wizard")];
    [o_t1_txt_text setStringValue: _NS("This wizard helps you to stream, transcode or save a stream")];
    [o_t1_btn_mrInfo_strmg setTitle: _NS("More Info")];
    [o_t1_btn_mrInfo_trnscd setTitle: _NS("More Info")];
    [o_t1_txt_notice setStringValue: _NS("This wizard only gives access to a small subset of VLC's streaming and transcoding capabilities. Use the Open and Stream Output dialogs to get all of them")];
	[[o_t1_matrix_strmgOrTrnscd cellAtRow:0 column:0] setTitle: _NS("Stream to network")];
    [[o_t1_matrix_strmgOrTrnscd cellAtRow:1 column:0] setTitle: _NS("Transcode/Save to file")];
    
    /* page two ("Input") */
    [o_t2_title setStringValue: _NS("Choose input")];
    [o_t2_text setStringValue: _NS("Choose here your input stream")];
    [[o_t2_matrix_inputSourceType cellAtRow:0 column:0] setTitle: _NS("Select a stream")];
    [[o_t2_matrix_inputSourceType cellAtRow:1 column:0] setTitle: _NS("Existing playlist item")];
    [o_t2_btn_chooseFile setTitle: _NS("Choose...")];
    [[[o_t2_tbl_plst tableColumnWithIdentifier:@"name"] headerCell] setStringValue: _NS("Name")];
    [[[o_t2_tbl_plst tableColumnWithIdentifier:@"uri"] headerCell] setStringValue: _NS("URI")];
    [o_t2_box_prtExtrct setTitle: _NS("Partial Extract")];
    [o_t2_ckb_enblPartExtrct setTitle: _NS("Enable")];
    [o_t2_txt_prtExtrctFrom setStringValue: _NS("From")];
    [o_t2_txt_prtExtrctTo setStringValue: _NS("To")];
    
    /* page three ("Streaming 1") */
    [o_t3_txt_title setStringValue: _NS("Streaming")];
    [o_t3_txt_text setStringValue: _NS("In this page, you will select how your input stream will be sent.")];
    [o_t3_box_dest setTitle: _NS("Destination")];
    [o_t3_box_strmgMthd setTitle: _NS("Streaming method")];
    [o_t3_txt_destInfo setStringValue: _NS("Enter the address of the computer to stream to")];
    [[o_t3_matrix_stmgMhd cellAtRow:1 column:0] setTitle: _NS("UDP Unicast")];
    [[o_t3_matrix_stmgMhd cellAtRow:1 column:1] setTitle: _NS("UDP Multicast")];
    
    /* page four ("Transcode 1") */
    [o_t4_title setStringValue: _NS("Transcode")];
    [o_t4_text setStringValue: _NS("If you want to change the compression format of the audio or video tracks, fill in this page. (If you only want to change the container format, proceed to next page).")];
    [o_t4_box_audio setTitle: _NS("Audio")];
    [o_t4_box_video setTitle: _NS("Video")];
    [o_t4_ckb_audio setTitle: _NS("Transcode audio")];
    [o_t4_ckb_video setTitle: _NS("Transcode video")];
    [o_t4_txt_videoBitrate setStringValue: _NS("Bitrate (kb/s)")];
    [o_t4_txt_videoCodec setStringValue: _NS("Codec")];
    [o_t4_txt_hintAudio setStringValue: _NS("If your stream has audio and you want to " \
                         "transcode it, enable this")];
    [o_t4_txt_hintVideo setStringValue: _NS("If your stream has video and you want to " \
                         "transcode it, enable this")];
    
    /* page five ("Encap") */
    [o_t5_title setStringValue: _NS("Encapsulation format")];
    [o_t5_text setStringValue: _NS("In this page, you will select how the stream will be "\
                     "encapsulated. Depending on the choices you made, all "\
                     "formats won't be available.")];
    
    /* page six ("Streaming 2") */
    [o_t6_title setStringValue: _NS("Additional streaming options")];
    [o_t6_text setStringValue: _NS("In this page, you will define a few " \
                              "additional parameters for your stream.")];
    [o_t6_txt_ttl setStringValue: _NS("Time-To-Live (TTL)")];
    [o_t6_btn_mrInfo_ttl setTitle: _NS("More Info")];
    [o_t6_ckb_sap setTitle: _NS("SAP Announce")];
    [o_t6_btn_mrInfo_sap setTitle: _NS("More Info")];
     
    /* page seven ("Transcode 2") */
    [o_t7_title setStringValue: _NS("Additional transcode options")];
    [o_t7_text setStringValue: _NS("In this page, you will define a few " \
                              "additionnal parameters for your transcoding.")];
    [o_t7_txt_saveFileTo setStringValue: _NS("Select the file to save to")];
    [o_t7_btn_chooseFile setTitle: _NS("Choose...")];
	
	/* page eight ("Summary") */
	/* FIXME: currently not implemented as it unsure whether we show this tab
	 * to the public or use it for debugging only */
	
	/* wizard help window */
	[o_wh_btn_okay setTitle: _NS("OK")];
}

- (IBAction)cancelRun:(id)sender
{
    [o_wizard_window close];
}

- (IBAction)nextTab:(id)sender
{
	if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Hello"])
	{
		/* check whether the user wants to stream or just to transcode;
		 * store information for later usage */
		NSString *o_mode;
		o_mode = [[o_t1_matrix_strmgOrTrnscd selectedCell] title];
		if( [o_mode isEqualToString: _NS("Stream to network")] )
		{
			[o_userSelections setObject:@"strmg" forKey:@"trnscdOrStrmg"];
		}else{
			[o_userSelections setObject:@"trnscd" forKey:@"trnscdOrStrmg"];
		}
		[o_btn_backward setEnabled:YES];
		[o_tab_pageHolder selectTabViewItemAtIndex:1];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Input"])
	{
		/* check whether partialExtract is enabled and store the values, if needed */
		if ([o_t2_ckb_enblPartExtrct state] == NSOnState)
		{
			[o_userSelections setObject:@"YES" forKey:@"partExtract"];
			[o_userSelections setObject:[o_t2_fld_prtExtrctFrom stringValue] forKey:@"partExtractFrom"];
			[o_userSelections setObject:[o_t2_fld_prtExtrctTo stringValue] forKey:@"partExtractTo"];
		}else{
			[o_userSelections setObject:@"NO" forKey:@"partExtract"];
		}
		
		/* check whether we use an existing pl-item or add an new one;
		 * store the path or the index and set a flag.
		 * complain to the user if s/he didn't provide a path */
		NSString *o_mode;
		o_mode = [[o_t2_matrix_inputSourceType selectedCell] title];
		if( [o_mode isEqualToString: _NS("Select a stream")] )
		{
			[o_userSelections setObject:@"YES" forKey:@"newStrm"];
			if ([[o_t2_fld_pathToNewStrm stringValue] isEqualToString: @""])
			{
				/* FIXME: we should complain to the user that s/he didn't provide a path */
			}else{
				[o_userSelections setObject:[o_t2_fld_pathToNewStrm stringValue] forKey:@"pathToNewStrm"];
			}
		}else{
			[o_userSelections setObject:@"NO" forKey:@"newStrm"];
			NSNumber * myNumber = [[NSNumber alloc] initWithInt:[o_t2_tbl_plst selectedRow]];
			[o_userSelections setObject:myNumber forKey:@"plItemIndex"];
		}
		
		/* show either "Streaming 1" or "Transcode 1" to the user */
		if ([[o_userSelections objectForKey:@"trnscdOrStrmg"] isEqualToString:@"strmg"])
		{
			/* we are streaming */
			[o_tab_pageHolder selectTabViewItemAtIndex:2];
		}else{
			/* we are just transcoding */
			[o_tab_pageHolder selectTabViewItemAtIndex:3];
		}
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Streaming 1"])
	{
		/* check which streaming method is selected and store it */
		NSString *o_mode;
		o_mode = [[o_t3_matrix_stmgMhd selectedCell] title];
		if( [o_mode isEqualToString: _NS("HTTP")] )
		{
			[o_userSelections setObject:@"HTTP" forKey:@"stmgMhd"];
			/* enable MPEG PS, MPEG TS, MPEG 1, OGG, RAW and ASF; select MPEG PS */
			[[o_t5_matrix_encap cellAtRow:0 column:0] setEnabled:YES];
			[[o_t5_matrix_encap cellAtRow:1 column:0] setEnabled:YES];
			[[o_t5_matrix_encap cellAtRow:2 column:0] setEnabled:YES];
			[[o_t5_matrix_encap cellAtRow:3 column:0] setEnabled:YES];
			[[o_t5_matrix_encap cellAtRow:4 column:0] setEnabled:YES];
			[[o_t5_matrix_encap cellAtRow:5 column:0] setEnabled:YES];
			[[o_t5_matrix_encap cellAtRow:6 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:7 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:8 column:0] setEnabled:NO];
			[o_t5_matrix_encap selectCellAtRow:0 column:0];
		} else {
			if( [o_mode isEqualToString: _NS("UDP Unicast")] )
			{
				[o_userSelections setObject:@"UDP-Unicast" forKey:@"stmgMhd"];
			} else {
				[o_userSelections setObject:@"UDP-Multicast" forKey:@"stmgMhd"];
			}
			/* disable all encap-formats but MPEG-TS and select it */
			[[o_t5_matrix_encap cellAtRow:0 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:2 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:3 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:4 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:5 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:6 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:7 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:8 column:0] setEnabled:NO];
			[[o_t5_matrix_encap cellAtRow:1 column:0] setEnabled:YES];
			[o_t5_matrix_encap selectCellAtRow:1 column:0];
		}
		
		/* store the destination and check whether is it empty */
		if( [[o_t3_fld_address stringValue] isEqualToString: @""] )
		{	/* FIXME: complain to the user that "" is no valid dest. */
		} else {
			[o_userSelections setObject:[o_t3_fld_address stringValue] forKey:@"stmgDest"];
		}
		
		/* let's go to the encap-tab */
		[o_tab_pageHolder selectTabViewItemAtIndex:4];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Transcode 1"])
	{
		/* check whether the user wants to transcode the video-track and store the related options */
		if ([o_t4_ckb_video state] == NSOnState)
		{
			NSNumber * theNum;
			theNum = [NSNumber numberWithInt:[o_t4_pop_videoCodec indexOfSelectedItem]];
			[o_userSelections setObject:@"YES" forKey:@"trnscdVideo"];
			[o_userSelections setObject:[o_t4_pop_videoBitrate titleOfSelectedItem] forKey:@"trnscdVideoBitrate"];
			[o_userSelections setObject:theNum forKey:@"trnscdVideoCodec"];
		} else {
			[o_userSelections setObject:@"NO" forKey:@"trnscdVideo"];
		}
		
		/* check whether the user wants to transcode the audio-track and store the related options */
		if ([o_t4_ckb_audio state] == NSOnState)
		{
			NSNumber * theNum;
			theNum = [NSNumber numberWithInt:[o_t4_pop_audioCodec indexOfSelectedItem]];
			[o_userSelections setObject:@"YES" forKey:@"trnscdAudio"];
			[o_userSelections setObject:[o_t4_pop_audioBitrate titleOfSelectedItem] forKey:@"trnscdAudioBitrate"];
			[o_userSelections setObject:theNum forKey:@"trnscdAudioCodec"];
		} else {
			[o_userSelections setObject:@"NO" forKey:@"trnscdAudio"];
		}
		
		/* FIXME: re-enable the "Encap"-tab depending on the chosen codecs */
		[o_tab_pageHolder selectTabViewItemAtIndex:4];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Encap"])
	{
		/* get the chosen encap format and store it */
		[o_userSelections setObject:[[o_t5_matrix_encap selectedCell] title] forKey:@"encapFormat"];
		
		/* show either "Streaming 2" or "Transcode 2" to the user */
		if ([[o_userSelections objectForKey:@"trnscdOrStrmg"] isEqualToString:@"strmg"])
		{
			/* we are streaming */
			[o_tab_pageHolder selectTabViewItemAtIndex:5];
		}else{
			/* we are just transcoding */
			[o_tab_pageHolder selectTabViewItemAtIndex:6];
		}
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Streaming 2"])
	{
		/* store the chosen TTL */
		[o_userSelections setObject:[o_t6_fld_ttl stringValue] forKey:@"ttl"];
		
		/* check whether SAP is enabled and store the announce, if needed */
		if ([o_t6_ckb_sap state] == NSOnState)
		{
			[o_userSelections setObject:@"YES" forKey:@"sap"];
			[o_userSelections setObject:[o_t6_fld_sap stringValue] forKey:@"sapText"];
		} else {
			[o_userSelections setObject:@"NO" forKey:@"sap"];
		}
		
		/* go to "Summary" */
		[self showSummary];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Transcode 2"])
	{
		/* check whether the path != "" and store it */
		if( [[o_t7_fld_filePath stringValue] isEqualToString: @""] )
		{	/* FIXME: complain to the user that "" is no valid path */
		} else {
			[o_userSelections setObject:[o_t7_fld_filePath stringValue] forKey:@"trnscdFilePath"];
		}
		
		/* go to "Summary" */
		[self showSummary];
	}
}

- (void)showSummary
{
	[o_btn_forward setTitle: _NS("Finish")];
	if ([[o_userSelections objectForKey:@"newStrm"] isEqualToString: @"YES"])
	{
		[o_t8_fld_inptStream setStringValue:[o_userSelections objectForKey:@"pathToNewStrm"]];
	} else {
		[o_t8_fld_inptStream setStringValue:[[o_userSelections objectForKey:@"plItemIndex"] stringValue]];
	}
	if ([[o_userSelections objectForKey:@"partExtract"] isEqualToString: @"YES"])
	{
		[o_t8_fld_partExtract setStringValue: [[[[[_NS("yes") stringByAppendingString:@" - "] stringByAppendingString: _NS("from ")] stringByAppendingString: [o_userSelections objectForKey:@"partExtractFrom"]] stringByAppendingString: _NS(" to ")] stringByAppendingString: [o_userSelections objectForKey:@"partExtractTo"]]];
	} else {
		[o_t8_fld_partExtract setStringValue: _NS("no")];
	}
	
	if ([[o_userSelections objectForKey:@"trnscdOrStrmg"] isEqualToString:@"strmg"])
	{
		/* we are streaming; no transcoding allowed atm */
		[o_t8_fld_saveFileTo setStringValue: @"-"];
		[o_t8_fld_trnscdAudio setStringValue: @"-"];
		[o_t8_fld_trnscdVideo setStringValue: @"-"];
		[o_t8_fld_strmgMthd setStringValue: [o_userSelections objectForKey:@"stmgMhd"]];
		[o_t8_fld_destination setStringValue: [o_userSelections objectForKey:@"stmgDest"]];
		[o_t8_fld_ttl setStringValue: [o_userSelections objectForKey:@"ttl"]];
		if ([[o_userSelections objectForKey:@"sap"] isEqualToString: @"YES"])
		{
			[o_t8_fld_sap setStringValue: [[_NS("yes") stringByAppendingString:@": "] stringByAppendingString:[o_userSelections objectForKey:@"sapText"]]];
		}else{
			[o_t8_fld_sap setStringValue: _NS("no")];
		}
	} else {
		/* we are transcoding */
		[o_t8_fld_strmgMthd setStringValue: @"-"];
		[o_t8_fld_destination setStringValue: @"-"];
		[o_t8_fld_ttl setStringValue: @"-"];
		[o_t8_fld_sap setStringValue: @"-"];
		if ([[o_userSelections objectForKey:@"trnscdVideo"] isEqualToString:@"YES"])
		{
			[o_t8_fld_trnscdVideo setStringValue: [[[[[_NS("yes") stringByAppendingString:@": "] stringByAppendingString: [[o_videoCodecs objectAtIndex:[[o_userSelections objectForKey:@"trnscdVideoCodec"] intValue]] objectAtIndex:0]] stringByAppendingString:@" @ "] stringByAppendingString: [o_userSelections objectForKey:@"trnscdVideoBitrate"]] stringByAppendingString:@" kb/s"]];
		}else{
			[o_t8_fld_trnscdVideo setStringValue: _NS("no")];
		}
		if ([[o_userSelections objectForKey:@"trnscdAudio"] isEqualToString:@"YES"])
		{
			[o_t8_fld_trnscdAudio setStringValue: [[[[[_NS("yes") stringByAppendingString:@": "] stringByAppendingString: [[o_audioCodecs objectAtIndex:[[o_userSelections objectForKey:@"trnscdAudioCodec"] intValue]] objectAtIndex:0]] stringByAppendingString:@" @ "] stringByAppendingString: [o_userSelections objectForKey:@"trnscdAudioBitrate"]] stringByAppendingString:@" kb/s"]];
		}else{
			[o_t8_fld_trnscdAudio setStringValue: _NS("no")];
		}
		[o_t8_fld_saveFileTo setStringValue: [o_userSelections objectForKey:@"trnscdFilePath"]];
	}
	[o_t8_fld_encapFormat setStringValue: [o_userSelections objectForKey:@"encapFormat"]];
	[o_tab_pageHolder selectTabViewItemAtIndex:7];
}

- (IBAction)prevTab:(id)sender
{
    if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Summary"])
	{	
		/* check whether we are streaming or transcoding and go back */
		if ([[o_userSelections objectForKey:@"trnscdOrStrmg"] isEqualToString:@"strmg"])
		{
			/* show "Streaming 2" */
			[o_tab_pageHolder selectTabViewItemAtIndex:5];
		}else{
			/* show "Transcode 2" */
			[o_tab_pageHolder selectTabViewItemAtIndex:6];
		}
		/* rename the forward-button */
		[o_btn_forward setTitle: [_NS("Next") stringByAppendingString:@" >"]];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Transcode 2"])
	{
		/* show "Encap" */
		[o_tab_pageHolder selectTabViewItemAtIndex:4];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Streaming 2"])
	{
		/* show "Encap" */
		[o_tab_pageHolder selectTabViewItemAtIndex:4];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Encap"])
	{
		/* check whether we are streaming or transcoding and go back */
		if ([[o_userSelections objectForKey:@"trnscdOrStrmg"] isEqualToString:@"strmg"])
		{
			/* show "Streaming 1" */
			[o_tab_pageHolder selectTabViewItemAtIndex:2];
		}else{
			/* show "Transcode 2" */
			[o_tab_pageHolder selectTabViewItemAtIndex:3];
		}
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Streaming 1"])
	{
		/* show "Input" */
		[o_tab_pageHolder selectTabViewItemAtIndex:1];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Transcode 1"])
	{
		/* show "Input" */
		[o_tab_pageHolder selectTabViewItemAtIndex:1];
	}
	else if ([[[o_tab_pageHolder selectedTabViewItem] label] isEqualToString: @"Input"])
	{
		/* show "Hello" */
		[o_tab_pageHolder selectTabViewItemAtIndex:0];
		/* disable backwards-btn */
		[o_btn_backward setEnabled:NO];
	}
}

- (IBAction)t1_mrInfo_streaming:(id)sender
{
    /* show a sheet for the help */
	/* since NSAlert does not exist on OSX < 10.3, we use our own implementation */
	[o_wh_txt_title setStringValue: _NS("Stream to network")];
	[o_wh_txt_text setStringValue: _NS("Use this to stream on a network.")];
	[NSApp beginSheet: o_wizardhelp_window
            modalForWindow: o_wizard_window
            modalDelegate: o_wizardhelp_window
            didEndSelector: nil
            contextInfo: nil];
}

- (IBAction)t1_mrInfo_transcode:(id)sender
{
    /* show a sheet for the help */
	[o_wh_txt_title setStringValue: _NS("Transcode/Save to file")];
	[o_wh_txt_text setStringValue: _NS("Use this to save a stream to a file. You "\
		"have the possibility to reencode the stream. You can save whatever "\
		"VLC can read.\nPlease notice that VLC is not very suited " \
		"for file to file transcoding. You should use its transcoding " \
        "features to save network streams, for example.")];
	[NSApp beginSheet: o_wizardhelp_window
            modalForWindow: o_wizard_window
            modalDelegate: o_wizardhelp_window
            didEndSelector: nil
            contextInfo: nil];
}

- (IBAction)t2_addNewStream:(id)sender
{
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    SEL sel = @selector(t2_getNewStreamFromDialog:returnCode:contextInfo:);
    [openPanel beginSheetForDirectory:nil file:nil types:nil modalForWindow:o_wizard_window modalDelegate:self didEndSelector:sel contextInfo:nil];
}

- (void)t2_getNewStreamFromDialog: (NSOpenPanel *)sheet returnCode: (int)returnCode contextInfo: (void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        [o_t2_fld_pathToNewStrm setStringValue:[sheet filename]];
        /* FIXME: store path in a global variable */
    }
}

- (IBAction)t2_chooseStreamOrPlst:(id)sender
{
    /* enable and disable the respective items depending on user's choice */
    NSString *o_mode;
    o_mode = [[o_t2_matrix_inputSourceType selectedCell] title];
	
	if( [o_mode isEqualToString: _NS("Select a stream")] )
    {
		[o_t2_btn_chooseFile setEnabled:YES];
		[o_t2_fld_pathToNewStrm setEnabled:YES];
		[o_t2_tbl_plst setEnabled:NO];
	} else {
		[o_t2_btn_chooseFile setEnabled:NO];
		[o_t2_fld_pathToNewStrm setEnabled:NO];
		[o_t2_tbl_plst setEnabled:YES];
	}
}

- (IBAction)t2_enableExtract:(id)sender
{
    /* enable/disable the respective items */
    if([o_t2_ckb_enblPartExtrct state] == NSOnState)
    {
        [o_t2_fld_prtExtrctFrom setEnabled:YES];
        [o_t2_fld_prtExtrctTo setEnabled:YES];
    } else {
        [o_t2_fld_prtExtrctFrom setEnabled:NO];
        [o_t2_fld_prtExtrctTo setEnabled:NO];
		[o_t2_fld_prtExtrctFrom setStringValue:@""];
		[o_t2_fld_prtExtrctTo setStringValue:@""];
    }
}

- (IBAction)t3_addressEntered:(id)sender
{
    /* check whether the entered address is valid */
}

- (IBAction)t4_AudCdcChanged:(id)sender
{
    /* update codec info */
	[o_t4_txt_hintAudio setStringValue:[[o_audioCodecs objectAtIndex:[o_t4_pop_audioCodec indexOfSelectedItem]] objectAtIndex:2]];
}

- (IBAction)t4_enblAudTrnscd:(id)sender
{
    /* enable/disable the respective items */
    if([o_t4_ckb_audio state] == NSOnState)
    {
        [o_t4_pop_audioCodec setEnabled:YES];
        [o_t4_pop_audioBitrate setEnabled:YES];
		[o_t4_txt_hintAudio setStringValue: _NS("Select your audio codec. "\
		"Click one to get more information.")];
    } else {
        [o_t4_pop_audioCodec setEnabled:NO];
        [o_t4_pop_audioBitrate setEnabled:NO];
		[o_t4_txt_hintAudio setStringValue: _NS("If your stream has audio " \
		"and you want to transcode it, enable this.")];
    }
}

- (IBAction)t4_enblVidTrnscd:(id)sender
{
    /* enable/disable the respective items */
    if([o_t4_ckb_video state] == NSOnState)
    {
        [o_t4_pop_videoCodec setEnabled:YES];
        [o_t4_pop_videoBitrate setEnabled:YES];
		[o_t4_txt_hintVideo setStringValue: _NS("Select your video codec. "\
		"Click one to get more information.")];
    } else {
        [o_t4_pop_videoCodec setEnabled:NO];
        [o_t4_pop_videoBitrate setEnabled:NO];
		[o_t4_txt_hintVideo setStringValue: _NS("If your stream has video " \
		"and you want to transcode it, enable this.")];
    }
}

- (IBAction)t4_VidCdcChanged:(id)sender
{
    /* update codec info */
	[o_t4_txt_hintVideo setStringValue:[[o_videoCodecs objectAtIndex:[o_t4_pop_videoCodec indexOfSelectedItem]] objectAtIndex:2]];
}

- (IBAction)t6_enblSapAnnce:(id)sender
{
    /* enable/disable input fld */
    if([o_t6_ckb_sap state] == NSOnState)
    {
        [o_t6_fld_sap setEnabled:YES];
    } else {
        [o_t6_fld_sap setEnabled:NO];
        [o_t6_fld_sap setStringValue:@""];
    }
}

- (IBAction)t6_mrInfo_ttl:(id)sender
{
    /* show a sheet for the help */
	[o_wh_txt_title setStringValue: _NS("Time-To-Live (TTL)")];
	[o_wh_txt_text setStringValue: _NS("Define the TTL (Time-To-Live) of the stream. "\
			"This parameter is the maximum number of routers your stream can go "
			"through. If you don't know what it means, or if you want to stream on " \
			"your local network only, leave this setting to 1.")];
	[NSApp beginSheet: o_wizardhelp_window
            modalForWindow: o_wizard_window
            modalDelegate: o_wizardhelp_window
            didEndSelector: nil
            contextInfo: nil];
}

- (IBAction)t6_mrInfo_sap:(id)sender
{
    /* show a sheet for the help */
	[o_wh_txt_title setStringValue: _NS("SAP Announce")];
	[o_wh_txt_text setStringValue: _NS("When streaming using UDP, you can " \
		"announce your streams using the SAP/SDP announcing protocol. This " \
		"way, the clients won't have to type in the multicast address, it " \
		"will appear in their playlist if they enable the SAP extra interface.\n" \
		"If you want to give a name to your stream, enter it here, " \
		"else, a default name will be used.")];
	[NSApp beginSheet: o_wizardhelp_window
            modalForWindow: o_wizard_window
            modalDelegate: o_wizardhelp_window
            didEndSelector: nil
            contextInfo: nil];
}

- (IBAction)t7_selectTrnscdDestFile:(id)sender
{
    /* provide a save-to-dialogue, so the user can choose a location for his/her new file */
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    SEL sel = @selector(t7_getTrnscdDestFile:returnCode:contextInfo:);
    [savePanel beginSheetForDirectory:nil file:nil modalForWindow:o_wizard_window modalDelegate:self didEndSelector:sel contextInfo:nil];
    /* FIXME: insert a suffix in file depending on the chosen encap-format instead of providing file:nil */
}

- (void)t7_getTrnscdDestFile: (NSSavePanel *)sheet returnCode: (int)returnCode contextInfo: (void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        [o_t7_fld_filePath setStringValue:[sheet filename]];
        /* FIXME: add a suffix depending on the chosen encap-format, if needed */
    }
}

- (IBAction)wh_closeSheet:(id)sender
{
	/* close the help sheet */
	[NSApp endSheet:o_wizardhelp_window];
	[o_wizardhelp_window close];
}

- (void)dealloc
{
	[o_userSelections release];
	[o_videoCodecs release];
	[o_audioCodecs release];
	[super dealloc];
}

@end
