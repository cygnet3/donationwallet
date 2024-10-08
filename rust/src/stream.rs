use std::sync::Mutex;

use crate::frb_generated::StreamSink;
use lazy_static::lazy_static;

lazy_static! {
    static ref SCAN_PROGRESS_STREAM_SINK: Mutex<Option<StreamSink<ScanProgress>>> =
        Mutex::new(None);
    static ref SCAN_RESULT_STREAM_SINK: Mutex<Option<StreamSink<ScanResult>>> = Mutex::new(None);
}

pub struct ScanProgress {
    pub start: u32,
    pub current: u32,
    pub end: u32,
}

pub struct ScanResult {
    pub updated_wallet: String,
}

pub fn create_scan_progress_stream(s: StreamSink<ScanProgress>) {
    let mut stream_sink = SCAN_PROGRESS_STREAM_SINK.lock().unwrap();
    *stream_sink = Some(s);
}

pub fn create_scan_result_stream(s: StreamSink<ScanResult>) {
    let mut stream_sink = SCAN_RESULT_STREAM_SINK.lock().unwrap();
    *stream_sink = Some(s);
}

pub(crate) fn send_scan_progress(scan_progress: ScanProgress) {
    let stream_sink = SCAN_PROGRESS_STREAM_SINK.lock().unwrap();
    if let Some(stream_sink) = stream_sink.as_ref() {
        stream_sink.add(scan_progress).unwrap();
    }
}

pub(crate) fn send_scan_result(scan_result: ScanResult) {
    let stream_sink = SCAN_RESULT_STREAM_SINK.lock().unwrap();
    if let Some(stream_sink) = stream_sink.as_ref() {
        stream_sink.add(scan_result).unwrap();
    }
}
