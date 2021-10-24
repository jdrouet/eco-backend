<?php

namespace App\Http\Controllers;

use App\Models\LogEntry;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller;

class LogEntryController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    public function search(Request $request) {
        $limit = $request->input('limit', '100');
        $offset = $request->input('offset', '0');

        return LogEntry::search($limit, $offset);
    }

    public function publish(Request $request) {
        $this->validate($request, [
            '*.createdAt' => 'required|numeric',
            '*.level' => 'required',
        ]);
        $data = $request->collect();
        foreach ($data as $item) {
            $entry = LogEntry::fromPayload($item);
            $entry->save();
        }

        return '';
    }
}
