<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Laravel\Lumen\Routing\Controller;

class EventController extends Controller
{
    private $blackholeUrl;

    public function __construct()
    {
        $this->blackholeUrl = env('BLACKHOLE_URL', 'http://localhost:3010');
    }

    public function publish(Request $request) {
        $data = $this->validate($request, [
            'ts' => 'required|numeric',
            'tags' => 'required',
            'tags.*' => 'string',
            'values' => 'required',
        ]);
        $data['tags']['through'] = 'php';
        $response = Http::post($this->blackholeUrl, $data);

        return response('', $response->status());
    }
}
